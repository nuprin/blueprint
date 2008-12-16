class AddStatusToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :status, :string, :default => "active"
  end

  def self.down
    remove_column :projects, :status
  end
end
