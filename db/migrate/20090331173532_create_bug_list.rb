class CreateBugList < ActiveRecord::Migration
  def self.up
    Task.prioritized.bugs.reverse.each do |t|
      TaskListItem.create!(:task_id => t.id, :context_type => "Bug",
        :context_id => 1)
    end
  end

  def self.down
    TaskListItem.destroy_all(:context_type => "Bug")
  end
end
