class CreateTaskSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :task_subscriptions do |t|
      t.integer :user_id
      t.integer :task_id
    end
    add_index :task_subscriptions, [:task_id, :user_id], :unique => true
  end

  def self.down
    drop_table :task_subscriptions
  end
end
