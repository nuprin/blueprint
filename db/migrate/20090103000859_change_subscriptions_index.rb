class ChangeSubscriptionsIndex < ActiveRecord::Migration
  def self.up
    remove_index :subscriptions,
      :name => :index_task_subscriptions_on_task_id_and_user_id
    add_index :subscriptions, [:entity_id, :entity_type, :user_id],
      :unique => true
  end

  def self.down
    add_index :subscriptions, [:task_id, :user_id], :unique => true
    remove_index :subscriptions, :column => [:entity_id, :entity_type, :user_id]
  end
end
