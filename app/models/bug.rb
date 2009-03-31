class Bug
  def self.task_list
    TaskListItem.find_all_by_context_type("Bug", :include => :task).map(&:task)
  end
end