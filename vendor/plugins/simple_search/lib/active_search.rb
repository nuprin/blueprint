module ActiveSearch
end

$:.unshift File.dirname(__FILE__)
$:.unshift File.dirname(__FILE__) + "/active_search"

%w( index_representations result indexer ).map{|f| require f }
%w( like term ).map{|f| require File.dirname(__FILE__) + '/active_search/' + f + '_indexer' }

begin
  require 'rubygems'
  require 'ferret'
  require File.dirname(__FILE__) + "/active_search/ferret_indexer"
rescue LoadError
  puts "ActiveSearch: Ferret is not available on this system"
end

unless defined?(ActiveSupport::Multibyte)
  raise "ActiveSearch _requires_ ActiveSupport::Multibyte, which is available in Rails 1.2.2 and newer"
end

module ActiveSearch

  def self.append_features(klass) #:nodoc:
    super
    klass.extend(ClassMethods)
  end
  
  # Returns all Indexers for a specific class. The class can be passed in as a class object or as a string/symbol
  def self.indexers(key)
    raise ArgumentError if key.nil?
    @@indexers ||= {}
    @@indexers[key.to_s] ||= []
    @@indexers[key.to_s]
  end
  
  
  # Returns all attributes of a class that are used internally (as fields for index storage for instance)
  def self.excluded_attributes_of(key)
    raise ArgumentError if key.nil?
    ActiveSearch::indexers(key).inject([]){|ar, idx| ar += idx.used_columns }.collect{ | att | att.to_sym }.uniq
  end

  def handle_indexes_on_update #:nodoc
    indexers.each do | idx | 
      idx.will_consume?(self) ? idx.handle_update(self) : idx.handle_delete(self)
    end
    return true
  end
  
  def handle_indexes_on_delete #:nodoc
    indexers.each { | idx | idx.handle_delete(self) }
    return true
  end
  
  def handle_indexes_after_create #:nodoc
    indexers.each { | idx | idx.handle_after_create(self) if idx.will_consume?(self)  }
    return true
  end
  
  def indexers
    ActiveSearch.indexers(self.class.to_s)
  end
end

module ActiveSearch::ClassMethods
  
  def indexes_columns (*fields) #:nodoc:
    
    supplied_options = (fields.last.is_a?(Hash) ? fields.pop.symbolize_keys : {})
    
    # Deduct indexer class
    identifier = supplied_options[:using]
    indexer = case 
      when identifier.nil?
        ActiveSearch::LikeIndexer.new(self)      
      when identifier.is_a?(Class)
        identifier.new(self)
      when identifier.is_a?(String), identifier.is_a?(Symbol)
        classname = supplied_options[:using].to_s.downcase.camelize + 'Indexer'
        begin
          indexer_class = Object.const_get(classname)
        rescue NameError
          indexer_class = ActiveSearch.const_get(classname)
        end
        indexer_class.new(self)
      else
        raise ActiveSearch::IndexSetupError, "Unknown indexer #{supplied_options[:using].to_s}"
    end

		supplied_options.delete(:using)
    
    supplied_options[:columns] = fields.collect{|f| f.to_sym} unless fields.empty?
    
    indexer.setup_with_options(supplied_options)
    
    # TODO - ensure callbacks reinstated even when model is reloaded
    self.send(:after_update, :handle_indexes_on_update)
    self.send(:after_create, :handle_indexes_after_create)
    self.send(:after_destroy, :handle_indexes_on_delete)
    
    # We setup indexing callbacks only for models that need it. Moreover we cannot have two indexes
    # created with identical options, so we take care of it here
    catch(:__dupe_indexer) do
      ActiveSearch.indexers(self).each do | idx |
        if idx.eql?(indexer)
          throw(:__dupe_indexer)
        end 
      end
      ActiveSearch.indexers(self) << indexer
    end        
  end

  # Finds any model objects that contain the suplied term
  def find_using_term(term)
		raise ActiveSearch::EmptyTermError if term.blank?
		
    indexers.inject([]) do | results, idx |
      results += idx.query(term)
    end.uniq
  end

  # This will process all of the models and generate indexes. Please note that the after_save
  # callbacks and validations are going to be omitted for speed reasons!
  def simply_reindex!
    ActiveSearch.indexers(self).each do |idx|
      idx.rebuild!
    end
  end
    
  # Tells if this model class has any indexers?
  def simply_searchable?
    ActiveSearch.indexers(self).any?
  end
  
  # Returns an array of all Indexers defined for this model
  def indexers
    ActiveSearch.indexers(self)
  end 
end

# Gets thrown when an index can't be setup with the supplied options
class ActiveSearch::IndexSetupError < RuntimeError
end

# Gets thrown åwhen an index can't be updated or rebuilt
class ActiveSearch::IndexRefreshError < RuntimeError
end

# Gets thrown if an empty term is passed
class ActiveSearch::EmptyTermError < RuntimeError
end