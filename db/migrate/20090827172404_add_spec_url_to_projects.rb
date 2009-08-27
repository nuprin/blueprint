class AddSpecUrlToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :spec_url, :string
  end

  def self.down
    remove_column :projects, :spec_url
  end
end
