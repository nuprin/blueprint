class Page < ActiveRecord::Base
  has_many :page_paras, :order=>'position ASC'
  belongs_to :page_author

  indexes_columns :page_author, :title, :body, :page_paras, :approved, :into=>'an_index' # LIKE index
  indexes_columns :page_author, :title, :body, :page_paras, :approved, :into=>'an_index' # LIKE index - copy

  indexes_columns :page_author, :title, :body, :page_paras, :using=>:term # Term-based index

  indexes_columns :title, :body, :into => 'another_index', :if => :approved? # LIKE index with conditional

  if $WITH_FERRET
    indexes_columns :page_author, :title, :body, :page_paras, :using=>:ferret # Ferret index
  end
  
  def to_s; title; end
end