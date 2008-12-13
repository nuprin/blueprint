class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :title, :null => false
      t.string :description, :limit => 5000

      t.string :kind, :limit => 32, :null => false
      t.string :status, :limit => 32, :null => false

      t.integer :project_id
      t.integer :creator_id, :null => false
      t.integer :assignee_id

      t.column :estimate, :tinyint
      t.date :due_date
      t.datetime :completed_at
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
