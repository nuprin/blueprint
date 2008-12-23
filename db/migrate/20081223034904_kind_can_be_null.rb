class KindCanBeNull < ActiveRecord::Migration
  def self.up
    change_column :tasks, :kind, :string, :limit => 32, :null => true
  end

  def self.down
    change_column :tasks, :kind, :string, :limit => 32, :null => false
  end
end
