class AddCreatorIdToDeferredTask < ActiveRecord::Migration
  def self.up
    add_column :deferred_tasks, :creator_id, :integer
    DeferredTask.all.each do |dt|
      dt.update_attribute(:creator_id, dt.task.assignee_id)
    end
    change_column :deferred_tasks, :creator_id, :integer, :null => false
  end

  def self.down
    remove_column :deferred_tasks, :creator_id
  end
end
