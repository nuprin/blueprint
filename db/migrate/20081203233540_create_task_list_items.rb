class CreateTaskListItems < ActiveRecord::Migration
  def self.up
    create_table :task_list_items do |t|
      t.integer :task_id, :null => false
      t.integer :context_id, :null => false
      t.string :context_type, :limit => 32, :null => false
      t.column :position, :tinyint, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :task_list_items
  end
end
