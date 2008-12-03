class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :title
      t.string :description, :limit => 5000

      t.string :type, :limit => 32
      t.string :status, :limit => 32

      t.integer :project_id
      t.integer :creator_id
      t.integer :asignee_id

      t.column :estimate, :tinyint
      t.date :due_date

      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
