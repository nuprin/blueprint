class AddFeatureSupportToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :feature_id, :integer
  end

  def self.down
    remove_column :tasks, :feature_id
  end
end
