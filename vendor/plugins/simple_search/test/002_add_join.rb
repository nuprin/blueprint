class AddJoin < ActiveRecord::Migration
  def self.up
    create_table :page_authors_search_terms, :force => true, :id=>false do |t|
      t.column :search_term_id, :string
      t.column :page_author_id, :integer
    end
  end
  
  def self.down
    begin
      drop_table :page_authors_search_terms
    rescue ActiveRecord::StatementInvalid
    end
  end
  
  self.verbose = false
end