class PageAuthor < ActiveRecord::Base
  # A custom index representation example
  indexes_columns :except=>'bio', :into=>'other_searchable'
  
  # A custom index representation of a field
  def index_repr_of_first_name
    "mister #{first_name}"
  end
end