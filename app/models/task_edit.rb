class TaskEdit < ActiveRecord::Base
  belongs_to :editor, :class_name => "User"
  belongs_to :task

  RELEVANT_FIELDS = [
    "assignee_id", "completed_at", "description", "due_date", "estimate", 
    "project_id", "status", "title"
  ]

  def self.record_changes!(task)
    task.changes.each do |f, (o, n)|
      if RELEVANT_FIELDS.include?(f)
        self.create! :editor_id => task.editor.id, :task_id => task.id,
                     :field => f, :old_value => o, :new_value => n
      end
    end
  end
end
