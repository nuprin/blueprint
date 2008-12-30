class TaskMailer < ActionMailer::Base

  include TaskMailerHelper

  FROM_EMAIL           = "blueprint@causes.com"
  FROM_EMAIL_WITH_NAME = "Blueprint <#{FROM_EMAIL}>"

  default_url_options[:host] = HOST

  def task_creation(recipient, task)
    recipients recipient_email(recipient)
    from       from_email(task.creator)
    subject    task_subject(task)
    body       :task => task, :recipient => recipient
  end

  def task_comment(recipient, task, comment)
    recipients recipient_email(recipient)
    from       from_email(comment.author)
    subject    task_subject(comment.task)
    body       :comment => comment, :task => task
  end

  def task_due_date_changed(recipient, task)
    recipients recipient_email(recipient)
    from       task_editor_email(task)
    subject    task_subject(task)
    body       :task => task
  end
  
  def task_reassignment(recipient, task)
    assignee_was = User.find_by_id(task.assignee_id_was)

    recipients recipient_email(recipient)
    from       task_editor_email(task)
    subject    task_subject(task)
    body       :assignee_was => assignee_was, :task => task
  end

  def task_completion(recipient, task)
    recipients recipient_email(recipient)
    from       task_editor_email(task)
    subject    task_subject(task)
    body       :task => task
  end

  private
  
  def task_subject(task)
    "(##{task.id}) #{task.title}"
  end

  def recipient_email(recipient)
    "#{recipient.name} <#{recipient.email}>"
  end

  def from_email(user)
    "#{user.name} <#{FROM_EMAIL}>"
  end

  def task_editor_email(task)
    task.editor ? from_email(task.editor) : FROM_EMAIL_WITH_NAME
  end
end
