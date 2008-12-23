# A base indexer. Delegates most of methods to concrete Indexers.
class ActiveSearch::Indexer
  DEFAULT_OPTIONS = {
      :columns => :default,
      :except => [],
      :into => 'searchable',
      :including_associations => true,
      :using => :like,
      :if => true,
      :min_word_length => 4
  }
  
  attr_accessor :logger
  attr_accessor :creation_options
  attr_reader :used_columns
  
  # When initialized, an Indexer recieves the class object of the model as argument
  # and stores it's name as a symbol, not the class itself. This is done so that the class of the model
  # can be safely reloaded in Rails development mode
  def initialize(record_class)
    @klass = record_class.to_s.to_sym
    @used_columns = []
    @logger = record_class.logger
  end

  def setup_with_options(opt_hash)
    opts = ActiveSearch::Indexer::DEFAULT_OPTIONS.merge(self.class::DEFAULT_OPTIONS).merge(opt_hash.symbolize_keys)
    opts[:except] = [opts[:except]] unless opts[:except].is_a?(Array)
    
    possible_opts = (ActiveSearch::Indexer::DEFAULT_OPTIONS.keys + self.class::DEFAULT_OPTIONS.keys).uniq
    extraneous_opts = (opts.keys - possible_opts).map{|s| "'#{s}'" }.join(', ')    
    raise ActiveSearch::IndexSetupError, "A #{self.class} does not accept the options #{extraneous_opts}" if extraneous_opts.any?
    
    @downstream = opts[:including_associations]
      
    if opts[:columns] == :default
      opts[:columns] = automatically_indexed_columns.map{|c| c.to_s}
      if opts[:including_associations]
        opts[:columns] += klass.reflect_on_all_associations.map{|assoc| assoc.name.to_s }
      end
    else
      opts[:columns] = [opts[:columns]] unless opts[:columns].is_a?(Array)
      opts[:columns].map! { |c| c.to_s }
    end
    opts[:columns].uniq!
    opts[:columns] -= opts[:except].map {|c| c.to_s }
    opts[:columns] -= ActiveSearch::excluded_attributes_of(klass).map{|a|a.to_s}
    
    (@creation_options = opts).each{|o, v|
      instance_variable_set("@#{o}", v)
    }
    
    # Delegate to the concrete indexer for finishing the setup
    perform_setup
  end

  # Gets called when searching  
  def query(term)
    raise_on_empty_term(term)
  end
  
  # Get the list of columns used by the indexer for it's own needs
  def used_columns
    @used_columns.nil? ? [] : @used_columns.map{|c| c.to_sym }
  end
  
  # Prunes the index and clears it for new data
  def prune!
  end

  # Gets called when a record is created and has been persisted (when it already has an ID)    
  def handle_after_create(record)
    handle_update(record)
  end
  
  # Returns names of columns this indexer is harvesting
  def indexed_columns
    @columns.map{|c| c.to_sym } - ActiveSearch::excluded_attributes_of(klass)
  end

  # Gets called when a record is updated (use this to update the index)
  def handle_update(record)
  end

  # Gets called when a record is destroyed (use this to clean the index now orphaned index data)
  def handle_delete(record)
  end
  
  # Rebuilds the index
  def rebuild!
    klass.find(:all).each do |model|
      handle_update(model) && model.save(with_validation = false)
    end
  end

  # Should return true if this indexer is the same as another (used to prevent duplicate indexers)
  def eql?(another)
    (another.class == self.class) && (another.creation_options == self.creation_options)
  end
  
  # Sanitizez an index representation - remove stop words
  def self.sanitize_index_representation(repr)
    search_matrix = (repr.is_a?(String) ? repr.split(/\w/u) : repr)

    search_matrix.map!{|s|
      s.split(/\s/u)
    }

    search_matrix.flatten!
    search_matrix.compact!
    
    stops = '”“’'
    # generic cleanup #{stops}
    search_matrix.reject! { |p| p.blank? or !p.respond_to?(:gsub)}
    search_matrix.map!{ |s| 
        s.replace(s.gsub( /[^\w\s]/, '' ))
        s.replace(s.gsub( /\s+/, ' ')) # punctuation and whitespace
        s.replace(s.gsub( /[#{stops}]/u, '' )) # really friggin ridiculous yep?!
    }
    
    search_matrix.reject! { |p | p.blank? }
    search_matrix.uniq!
    search_matrix.join(" ").downcase # and here comes your index
  end
  
  # Evaluates the condition provided in the "if" option, if true - the index is updated or created
  def will_consume?(record)
    case @if
      when Symbol, String
        return (record.send(@if) ? true : false)            
      when Proc
        return (@if.call(record) ? true : false)
      when TrueClass
        return true
      else
        raise IndexSetupError, "Don't know how to evaluate conditional #{@if}"
    end
    true
  end

  private

    # Actual setup is performed here - this method gets a sanitized options hash merged
    # with the defaults. Your best bet would be to override this method.
    def perform_setup
    end

    # Converts a list of words into an array or a single word into an array,
    # removing AND and OR keywords
    def term_to_array(term)
      term = term.join(' ') if term.is_a?(Array)
      term.downcase!
      term.gsub!(/\Wand\W|\Wor\W/u, ' ')
      term.gsub!( /[^\w\s]/u, '' )
      term.gsub!(/\s+/u, ' ' )
      return [] if term.empty?
      terms = term.split(/\s/)
      terms.reject{|t| t.nil? or t.empty?}
    end

    # Composes an SQL conditions array comprising the request part (joined by AND)
    # passed in common_segment_with_placeholder, an array of terms and an enclosure.
    # Enclosure should contain %s that will be replaced by the search term.
    def compose_conditions(common_segment_with_placeholder, array_of_terms, enclosure = '%s')
      array_of_terms.map! { |term| enclosure.gsub(/%s/, term) }
      [([common_segment_with_placeholder]*array_of_terms.size).join(" AND ")] + array_of_terms 
    end

    # Returns the list of automatically indexed columns  
    def automatically_indexed_columns()
      self.class.automatically_indexed_columns(klass)
    end
            
    def self.automatically_indexed_columns(klass)
      cols = klass.column_names.reject do  |col|
        col =~ /_id$/ or col == klass.primary_key.to_s
      end.map do |e|
        e.to_sym
      end
    end

    # Returns the actual class object for the model. We use this instead of storing the class
    # directly to allow the Rails app to reload properly, otherwise we are messing up EVERYTHING
    # inside ActiveRecord. We also can't disallow our models to reload because this is frustrating.
    def klass
      Kernel::const_get(@klass)
    end

    def raise_on_empty_term(term)
      raise ActiveSearch::EmptyTermError if term.empty?
    end
end