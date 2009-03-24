class RemovePrivateTasks < ActiveRecord::Migration
  def self.up
    Task.update_all "type='Task'", "type='PrivateTask'"
  end

  def self.down
  end
end
