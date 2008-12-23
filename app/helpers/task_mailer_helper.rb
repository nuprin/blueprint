module TaskMailerHelper
  def task_type(task)
    task.kind.empty? ? 'task' : task.kind
  end
  
  def task_footer(task)
    fields = []
    if !task.subscribed_user_names.blank?
      fields << ["Subscribed", task.subscribed_user_names]
    end
    if task.project_id
      fields << ["Project", task.project.title]
    end
    if task.due_date
      fields << ["Due Date", task.due_date.strftime("%b %e")]
    end
    fields.map do |field|
      field.join(": ")
    end.join(" | ")
  end
end