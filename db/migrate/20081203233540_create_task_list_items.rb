class CreateTaskListItems < ActiveRecord::Migration
  def self.up
    create_table :task_list_items do |t|
      t.integer :task_id
      t.integer :context_id
      t.string :context_type, :limit => 32
      t.column :position, :tinyint

      t.timestamps
    end
  end

  def self.down
    drop_table :task_list_items
  end
end
