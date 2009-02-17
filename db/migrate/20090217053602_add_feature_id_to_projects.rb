class AddFeatureIdToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :feature_id, :integer
  end

  def self.down
    remove_column :projects, :feature_id
  end
end
