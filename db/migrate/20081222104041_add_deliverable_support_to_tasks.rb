class AddDeliverableSupportToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :type, :string, :null => false,
      :default => "Deliverable"
    add_column :tasks, :parent_id, :integer
  end

  def self.down
    remove_column :tasks, :parent_id
    remove_column :tasks, :type
  end
end
