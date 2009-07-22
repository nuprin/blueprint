class TaskEdit < ActiveRecord::Base
  belongs_to :editor, :class_name => "User"
  belongs_to :task

  named_scope :since, lambda {|t| {:conditions => {
    :created_at => t.getutc..Time.now.getutc
  }}}
  
  RELEVANT_FIELDS = [
    "assignee_id", "description", "due_date", "estimate", "project_id",
    "status", "title"
  ]

  def self.record_changes!(task)
    task.changes.each do |f, (o, n)|
      if RELEVANT_FIELDS.include?(f) && task.editor
        edit = self.create! :editor_id => task.editor.id, :task_id => task.id,
                            :field => f, :old_value => o, :new_value => n
        task.editor.subscribe_to(task) unless task.editor == User.butler
      end
    end
  end

  def self.record_subscription!(subscription, editor)
    self.create! :editor_id => editor.id, :task_id => subscription.task.id,
                 :field => "subscriptions", :new_value => subscription.user_id
  end

  def self.notify_subscribers_of_recent_edits(since)
    self.since(since).group_by(&:task).each do |task, edits|
      editors = edits.map(&:editor).uniq
      uninterested_users = []
      if editors.size == 1
        uninterested_users << editors.first
      end
      task.mass_mailer.ignoring(uninterested_users).deliver_recent_edits(edits)
    end
  end
end
