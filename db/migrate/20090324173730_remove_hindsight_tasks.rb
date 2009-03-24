class RemoveHindsightTasks < ActiveRecord::Migration
  def self.up
    Task.update_all "type='Task'", "type='HindsightTask'"
  end

  def self.down
  end
end
