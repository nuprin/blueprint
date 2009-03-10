class TaskEdit < ActiveRecord::Base
  belongs_to :editor, :class_name => "User"
  belongs_to :task

  RELEVANT_FIELDS = [
    "assignee_id", "description", "due_date", "estimate", "project_id",
    "status", "title"
  ]

  def self.record_changes!(task)
    task.changes.each do |f, (o, n)|
      # task.editor ||= User.task_master
      if RELEVANT_FIELDS.include?(f) && task.editor
        edit = self.create! :editor_id => task.editor.id, :task_id => task.id,
                            :field => f, :old_value => o, :new_value => n
        edit.notify_subscribers(task)        
      end
    end
  end

  def self.record_subscription!(subscription, editor)
    self.create! :editor_id => editor.id, :task_id => subscription.task.id,
                 :field => "subscriptions", :new_value => subscription.user_id
  end

  def notify_subscribers(task)
    deliver_method = "deliver_#{self.field}_edit"
    task.mass_mailer.ignoring(task.editor).send(deliver_method, self)
  end
end
