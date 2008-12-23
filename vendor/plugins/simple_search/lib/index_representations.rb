## Index representations for basic types
class Object::Time #:nodoc:
  def index_repr; strftime("%d %A %B %Y"); end
end

module ActiveSearch::IndexUnworthy  #:nodoc:
  def index_repr; ''; end
end

[TrueClass, FalseClass, NilClass].each {|c| c.send(:include, ActiveSearch::IndexUnworthy) }

class Object::Date #:nodoc:
  def index_repr; strftime("%d %A %B %Y"); end
end

class Object::Array #:nodoc:
  def index_repr
    map do |i|
      i.respond_to?(:index_repr) ? i.index_repr : i.to_s
    end.reject do |i|
      i.blank?
    end.join(" ")
  end
end

class Object::ActiveRecord::Base
  # This method should return the optimum string representation of an object for searching,
  # with words in lowercase separated by spaces. By default all ActiveRecords get a default
  # implementation, but if you want you can easily override it for every model that you have defined.
  # An indexer requesting the representation will be passed to the method
  # There can also be asked for the sanitized result - if so, an array shall be returned. Else a string should be returned.
  def index_repr(attribs_to_introspect = [])
    words = []
    
    # If we have an explicit list of fields to search, we use them.
    if attribs_to_introspect.empty?
      attribs_to_introspect = ActiveSearch::Indexer.automatically_indexed_columns(self.class)
    end
    
    attribs_to_introspect -= ActiveSearch::excluded_attributes_of(self.class)
    attribs_to_introspect.map!{ | c |
      respond_to?("index_repr_of_#{c}") ? ("index_repr_of_#{c}".to_sym) : c
    }
    
    attribs_to_introspect.each do |col|
      # Disable warnings because this can be the "type" column
      value = silence_warnings { send(col) }
      
      next if (value.respond_to?(:size) && value.size.zero?) || value.blank?
      
      # Handle predicates like "valid", "checked", "approved"
      san = if value.is_a?(TrueClass)
        Inflector::humanize(col)
      elsif  value.is_a?(FalseClass)
        ("Not " + Inflector::humanize(col))
      else
        value.respond_to?(:index_repr) ? value.index_repr : value.to_s
      end
      
      words << san
    end
    stops = /([^\w\s”“’»«])/
    words.map!{|w| w.chars.normalize(:kc) }
    words.map!{|w| w.gsub /([^\w\s]|[”“’»«])/, '' }
    words.join(" ").chars.downcase.to_s
  end
  
  # This works only automatically - it's a kind of a graph fetcher
  def index_repr_with_associations
    attrs = ActiveSearch::Indexer.automatically_indexed_columns(self.class)
    attrs += self.class.reflect_on_all_associations.map{|assoc| assoc.name.to_sym }
    index_repr(attrs)
  end
end