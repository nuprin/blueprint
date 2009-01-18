class AddCategoriesToInitiatives < ActiveRecord::Migration
  def self.up
    add_column :projects, :category_id, :integer
  end

  def self.down
    remove_column :projects, :category_id
  end
end
