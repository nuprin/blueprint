# ==Indexing into a terms table	
# Dumps the words contained in the index representation of an ActiveRecord::Base object into a separate table,
# joining the words to the record via a join table. Like this you can be much more precise how when handling
# searches, invict less load on the database (because there will be much less table scans needed than with LIKE)
# and also find out how many times a specific term is used (that might be handy for content analysis)
# 
# ==Options
# 	:columns - attributes to index (pulled from list of fields by default)
# 	:except - attributes to exclude from index
# 	:including_associations - if the associated objects should be included in the index
# 	:into - name of the database table that will store search terms. Default - 'search_terms'

class ActiveSearch::TermIndexer < ActiveSearch::Indexer
  DEFAULT_OPTIONS = {:columns=>:default, :into=>'search_terms', :including_associations=>true }

  def perform_setup
    @term_klass, @term_table, @join_table, @objects_sym = nil, nil, nil

    @index_table = @into
    @objects_sym = Inflector.pluralize(Inflector.underscore(klass)).to_sym
    
    # look if we have got search terms defined as a model
    @term_klass = Inflector.classify(@index_table).to_sym

    begin
      @term_klass = Kernel::const_get(@term_klass).to_s
      @term_table = term_klass.table_name
    rescue NameError
      if !klass.connection.tables.include?(@term_klass.to_s.tableize) 
        raise ActiveSearch::IndexSetupError, "You don't have a `#{@index_table}` table defined"
      end
      eval "class ::Object::#{@term_klass} < ActiveRecord::Base; end;" 
      Kernel::const_get(@term_klass).send(:validates_uniqueness_of, :term)
    end
    
    unless term_klass.instance_methods.include?(@objects_sym)
      term_klass.send(:has_and_belongs_to_many, @objects_sym)
    end
    
    unless klass.instance_methods.include?(Inflector.pluralize(term_klass.to_s).underscore)
      klass.send(:has_and_belongs_to_many, Inflector.pluralize(term_klass.to_s).underscore.to_sym)
    end

    @term_table = term_klass.table_name
    # Infer the join table from the association
    @join_table = term_klass.reflect_on_association(klass.to_s.underscore.pluralize.to_sym).options[:join_table]
    
    unless term_klass.connection.tables.include?(@join_table.to_s)
      raise ActiveSearch::IndexSetupError, "You don't have a `#{@join_table}` join table defined"
    end
    
    @used_columns << Inflector.pluralize(@term_klass.to_s).underscore
  end
    
  # Refresh the list of terms referring to the current record
  def handle_update(record)
    ind = record.index_repr(@columns).split(' ')
        
    unless record.new_record?
      term_klass.connection.execute "DELETE FROM #{@join_table} WHERE #{Inflector.underscore(klass)}_id = #{record.id}"
    end
    
		existing_terms = (ind.any? ? term_klass.find(:all, :conditions=>["#{term_klass.table_name}.term IN (?)", ind]) : [])
		
		for term in ind
			unless (term_object = existing_terms.find{|t| t.term == term})
				term_object = term_klass.find_or_create_by_term(term)
			end
			
			term_klass.connection.execute "INSERT INTO #{@join_table} (search_term_id, #{Inflector.underscore(klass)}_id)" +
        " VALUES(#{term_object.id}, #{record.id})"
    end
    return true
  end
  
  # Stubbed because we need after_create here
  def handle_create(record)
  end
  
  # Gets called when a record is created and has been persisted (when it already has an ID)    
  def handle_after_create(record)
    handle_update(record)
  end
  

  def handle_delete(record)
    klass.connection.execute "DELETE from #{@join_table} WHERE #{Inflector.underscore(klass)}_id = #{record.id}"
    return true
  end
  
  def prune!
    term_klass.connection.execute "DELETE FROM #{@join_table}"
  end

  def query(term)
    terms = term_to_array(term)
    raise_on_empty_term(terms)
    
    # The classic "find all records having related records A, B and C" type query
    cols = klass.column_names.reject{|c| c == klass.primary_key }.collect{|c| klass.table_name + '.' + c}.join(", ")
    result = klass.find(:all, :select=>"DISTINCT(#{klass.table_name}.#{klass.primary_key}), #{cols}",
        :joins=>"LEFT JOIN #{@join_table} AS jt0 \
                    ON jt0.#{Inflector.underscore(klass)}_id = #{klass.table_name}.id \
                 LEFT JOIN #{term_klass.table_name} AS jt1 \
                    ON jt0.#{Inflector.underscore(term_klass)}_id = jt1.#{term_klass.primary_key}",
        :conditions => ["jt1.term IN (?) AND #{klass.table_name}.id IS NOT NULL", terms],
        :group => "#{klass.table_name}.id, #{cols} HAVING COUNT(jt0.#{Inflector.underscore(term_klass)}_id) >= #{terms.length}",
        :readonly => false # because we're democratic and we know our SQL
    )
  end

  def rebuild!
    term_klass.delete_all
    term_klass.connection.execute "DELETE FROM #{@join_table}"
    klass.find(:all).each do |model|
      handle_update(model)
    end
  end
  
  private
    def term_klass
      Kernel::const_get(@term_klass)
    end
end