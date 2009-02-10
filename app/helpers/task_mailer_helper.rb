module TaskMailerHelper
  def task_type(task)
    task.kind.blank? ? "task" : task.kind
  end
  
  def task_footer(task)
    fields = []
    if !task.subscribed_user_names.blank?
      fields << ["Subscribed", task.subscribed_user_names]
    end
    if task.project_id
      fields << ["Initiative", task.project.title]
    end
    if task.due_date
      fields << ["Due Date", task.due_date.strftime("%b %e")]
    end
    fields << ["Status", task.status.capitalize]
    fields.map do |field|
      field.join(": ")
    end.join(" | ")
  end

  def task_editor_name(task)
    task.editor ? task.editor.name : "Someone"
  end
end