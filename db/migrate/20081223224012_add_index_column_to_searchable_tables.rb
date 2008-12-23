class AddIndexColumnToSearchableTables < ActiveRecord::Migration
  def self.up
    [:projects, :tasks, :specs, :comments].each do |table|
      add_column table, :searchable, :text
    end
  end

  def self.down
    [:projects, :tasks, :specs, :comments].each do |table|
      remove_column table, :searchable
    end
  end
end
