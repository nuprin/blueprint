class AddDueDateAndMissionToProjects < ActiveRecord::Migration
  def self.up
    add_column    :projects, :due_date, :date
    add_column    :projects, :mission,  :string, :limit => 1000
    remove_column :projects, :description
  end

  def self.down
    remove_column :projects, :due_date
    remove_column :projects, :mission
    add_column    :projects, :description, :string, :limit => 5000
  end
end
