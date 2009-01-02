class MakeTaskSubscriptionsPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :task_subscriptions, :task_id, :entity_id
    add_column    :task_subscriptions, :entity_type, :string,
                  :default => "Task"
    rename_table :task_subscriptions, :subscriptions
  end

  def self.down
    rename_column :subscriptions, :entity_id, :task_id
    remove_column :subscriptions, :entity_type
    rename_table  :subscriptions, :task_subscriptions
  end
end
