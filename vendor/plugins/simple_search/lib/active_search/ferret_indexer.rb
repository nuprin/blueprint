# ==Indexing into Ferret
# Ferret by Dave Balmain is a highly configurable, powerful port of Lucene to Ruby and C.
# It stores it's indexes in it's own format, so integrating it with ActiveRecord is not very
# easy - however this Indexer should give you a reasonable start. Take care to configure the underlying
# Ferret::Index::Index object yourself to achieve optimum search results.
# 
# Primarily because Ferret is so flexible, this indexer also accepts a "by" option, which will
# allow you to customize the index update procedure when records are updated. The Ferret index and the record are going to be
# passed to the proc.
# 
# This indexer does not use the ActiveRecord::Base#index_repr method, but instead
# will delegate tokenization and typecasting to Ferret. This, by default, will give you very good string representations
# of objects such as Date, Time etc.
# 
# However, if you define "index_repr_of_attribute" for one or more attributes the indexer is going to use them.
# 
# ==Options
#   :columns - attributes to index (pulled from list of fields by default)
#   :except - attributes to exclude from index
#   :including_associations - if the associated objects should be included in the index
#   :separate_columns - if separate columns should be created the columns will be saved
#         as Ferret document fields. Othwerise all will be indexed
#         into one document field called "content"
#   :by - can contain a proc, that will get the Ferret index and the record passed
#   :into - path to Ferret index
#   :ferret_options - hash of Ferret options to pass to the Ferret::Index::Index on creation

require 'fileutils'

class ActiveSearch::FerretIndexer < ActiveSearch::Indexer

  attr_accessor :ferret_index, :index_searcher, :query_parser

  DEFAULT_INDEX_EXTENSION = 'ferret'
  
  DEFAULT_FERRET_OPTIONS = {
      :path => File.join(RAILS_ROOT, 'tmp', "ferret-indexes"),
      :default_field=>'*',
      :key=>'ar_pkey_value',
      :auto_flush => true,
  }
  
  DEFAULT_OPTIONS = {
      :columns => :default,
      :into => DEFAULT_FERRET_OPTIONS[:path],
      :including_associations => true,
      :ferret_options => DEFAULT_FERRET_OPTIONS,
      :separate_columns => false,
      :by => nil,
  }

  def setup_with_options(options)
    super(options)
    
    options[:ferret_options] = DEFAULT_FERRET_OPTIONS.merge(options[:ferret_options] || {})
    
    if options[:into]
      options[:ferret_options][:path] = options[:into]
    else # default path, segregate per class
      options[:ferret_options][:path] = File.join(options[:ferret_options][:path], klass.to_s)
    end
    
    options[:ferret_options][:key] = klass.primary_key
    
    @separately = options[:separate_columns]
    @indexing_proc = options[:by]
    @index_needs_setup = allocate_index_directory_if_necessary(options[:ferret_options][:path])
    @ferret_index = Ferret::Index::Index.new(creation_options[:ferret_options])    
    
    if @index_needs_setup
      field_opts = {:store => :yes, :index => :yes}
      [:ar_class, :ar_pkey_value].map do | col |
        @ferret_index.field_infos.add_field(col, field_opts)
      end
      
      (options[:separate_columns] ? @columns : [:contents]).each do | attribute |
          @ferret_index.field_infos.add_field(attribute, field_opts)
      end
    end
  end
  
  def allocate_index_directory_if_necessary(path)
    (File.exist?(path) && File.directory?(path)) ?  !!FileUtils.mkdir_p(path) : false
  end
  
  def handle_delete(record)
    pk = record[record.class.primary_key]
    @ferret_index.delete(pk)
  end
  
  def rebuild!
    self.prune! # first wipe the index clean
    
    klass.find(:all).each do |r|
      @ferret_index <<  record_to_ferret_document(r)
    end
  end
  
  # Prunes the index
  def prune!
    (0..@ferret_index.size).each {|id| @ferret_index.delete(id) }
  end

  def update_by_id(record)
    handle_delete(record)
    
    doc = record_to_ferret_document(record)
    @ferret_index << doc
    @ferret_index.flush()
  end
  
  def handle_after_create(record)
    update_by_id(record)
  end
  
  def handle_update(record)
    update_by_id(record)
  end
  
  # Returns the actual Ferret index
  def ferret_index
    @ferret_index
  end
  
  def size
    @ferret_index.size
  end
  
  def query(query, options = {})
    
    raise_on_empty_term(query)
    results = []
    
    # Filtering allows us to have not only different classes in the same STI chain
    # but also different models writing to the same index. We only scan for this
    # specific class and not it's descendants because a record gets indexed
    # with all ancestors included
    query = "contents:(#{query}) AND (ar_class:#{klass.to_s.underscore})"
        
    @ferret_index.search_each(query) do | doc_offset, score|
       lazy = @ferret_index[doc_offset]
       id_to_lookup = @ferret_index[doc_offset][:ar_pkey_value]
       kls_tree = @ferret_index[doc_offset][:ar_class]
       kls = kls_tree.is_a?(Array) ? kls_tree[0] : kls_tree
       record_class = kls.classify.constantize
       
       # wrap in result
       begin
         result = ActiveSearch::FerretResult.new(record_class.find(id_to_lookup), lazy, lazy.fields)
         results << result unless results.include?(result)
       rescue ActiveRecord::RecordNotFound => e
       end
    end
    
    results.uniq
  end
  
  private
    
    def with_exclusive_write_access(&block)
      yield
    end
    
    def record_to_ferret_document(record)
      
      # delegate to the proc if defined
      if @indexing_proc.respond_to?(:call)
        doc = @indexing_proc.call(@ferret_index, record, @columns) 
        unless doc.is_a?(Ferret::Document::Document)
          raise IndexRefreshError, "The object returned by the indexing proc should be a Ferret::Document!"
        end
        return doc
      end
      
      doc = Ferret::Document.new
      doc[:ar_pkey_value] = record[record.class.primary_key].to_s
      
      # ar_class contains the whole inheritance chain UP from this specific class
      # We use that instead of the specific class of the record being indexed
      # because we never know if all the descendants of a specific record
      # class have been loaded into the environment, so we will index
      # bottom-up and then search from the top of the stack
      k = record.class
      all_ancestors = k.ancestors.slice(0...k.ancestors.index(ActiveRecord::Base))
      # Only index classes, not modules
      all_ancestors.reject!{|e| !e.is_a?(Class) }
      
      doc[:ar_class] = all_ancestors.map{|e| e.to_s.underscore }
      
      fields = {}
      record_assocs = record.class.reflect_on_all_associations.collect{|a| a.name.to_s }
      
      @columns.each do | col |
        # specifics first
        if record.respond_to?("index_repr_of_#{col}")
          fields[col] = record.send("index_repr_of_#{col}")
        # collections second - as multiple field values
        elsif record_assocs.include?(col.to_s) and record.send(col).is_a?(Array) and @downstream
          fields[col] = []
          record.send(col).each { |subrecord| fields[col] << subrecord.index_repr }
        # associations third
        elsif record_assocs.include?(col.to_s) and @downstream
          fields[col] = record.send(col).index_repr
        # conventionals last
        elsif !record_assocs.include?(col.to_s) 
          fields[col] = record.send(col)
        end
      end

      if @separately      
        fields.each_pair do |k, v|
          if v.is_a?(Array)
            v.each{|part| doc << Ferret::Document::Field.new(k, part, *field_parameters) }
          else
            doc[k] = v
          end
        end
      else
        doc[:contents] = fields.values.join("\n")
      end
      doc
    end
end

# Offers result_score and other Ferret meta (accessible through Result#document), while passing
# all the other messages to the ActiveRecord underneath.
class ActiveSearch::FerretResult < ActiveSearch::Result
  attr_accessor :indexed_fields
  FIELD_P = /^_indexed/
  
  def initialize(record, ferret_document, field_list)
    @indexed_fields = field_list
    @record, @document, @result_score = record, ferret_document, 0
  end
  
  def id
    @record.id
  end
    
  def method_missing(me, *args)
    (me =~ FIELD_P) ? @document[(me.gsub FIELD_P, '').to_sym] :  super(me, *args)
  end
end