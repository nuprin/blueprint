class CreateDeferredTasks < ActiveRecord::Migration
  def self.up
    create_table :deferred_tasks do |t|
      t.integer :task_id
      t.datetime :prioritize_at
    end
  end

  def self.down
    drop_table :deferred_tasks
  end
end
