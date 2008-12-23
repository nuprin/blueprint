# ==Indexing into a column
# Dumps the index representation of an ActiveRecord::Base object into a separate column for searching. You can limit
# the length of the column to a VARCHAR, the index will then be truncated to match the length of the column.
#
# ==Options
#   :columns - attributes to index (pulled from list of fields by default)
#   :except - attributes to exclude from index
#   :including_associations - if the associated objects should be included in the index
#   :into - name of the attribute of the record that will hold the index text. Default - 'searchable'.
#   

class ActiveSearch::LikeIndexer < ActiveSearch::Indexer
  DEFAULT_OPTIONS = {
    :columns => :default,
    :except => [],
    :into => 'searchable',
    :including_associations => true
  }

  def perform_setup
    unless klass.column_names.include?(@into.to_s)
      raise ActiveSearch::IndexSetupError, "Your table #{klass.table_name} does not have a column #{@into} \
to store the index!" 
    end
  end
  
  def used_columns
    [index_column_name]
  end
  
  def index_column_name
    @into.to_sym
  end
  
  def prune!
    klass.update_all("#{@into} = NULL")
  end

  def query(term)
    raise_on_empty_term(term)    
    terms = term_to_array(term)
    conditions = compose_conditions("#{@into} LIKE ?", terms, "%%s%")
    klass.find(:all, :conditions=>conditions)
  end

  def handle_update(record)
    repr = record.index_repr(@columns)
    unless record.class.columns.find{|c|c.name == @into}.limit.nil?
      limit = record.class.columns.find{|c|c.name == @into}.limit     
      repr.gsub!(/\s(\w+)$/, '') until repr.length < limit
    end
    record[@into] = repr
  end
  
  def handle_delete(record)
    record[@into] = nil unless record.frozen?
  end
  
  def handle_create(record)
    handle_update(record) if will_consume?(record)
  end
end
