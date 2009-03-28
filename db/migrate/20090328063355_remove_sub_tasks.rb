class RemoveSubTasks < ActiveRecord::Migration
  def self.up
    Task.update_all "type='Task'", "type='SubTask'"
  end

  def self.down
  end
end
