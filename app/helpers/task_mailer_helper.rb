module TaskMailerHelper
  def task_type(task)
    task.kind.empty? ? 'task' : task.kind
  end
end