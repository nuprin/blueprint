class CreateTaskEdits < ActiveRecord::Migration
  def self.up
    create_table :task_edits do |t|
      t.integer  :editor_id
      t.integer  :task_id
      t.string   :field
      t.string   :old_value
      t.string   :new_value
      t.datetime :created_at
    end
    add_index :task_edits, :task_id
  end

  def self.down
    drop_table :task_edits
  end
end
