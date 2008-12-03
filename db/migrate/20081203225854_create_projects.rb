class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :title, :null => false
      t.string :description, :limit => 5000

      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
