class Bug
  def self.task_list
    find_options = {:include => :task, :order => :position}
    TaskListItem.find_all_by_context_type("Bug", find_options)
  end
  
  def self.add_to_bug_task_list(task)
    options = {:task_id => task.id, :context_type => "Bug", :context_id => 1}
    TaskListItem.create(options)
  end

  def self.remove_from_bug_task_list(task)
    options = {:task_id => task.id, :context_type => "Bug", :context_id => 1}
    TaskListItem.destroy_all(options)
  end
end