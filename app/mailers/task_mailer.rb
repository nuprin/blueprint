class TaskMailer < ActionMailer::Base

  include MailerHelper
  include TaskMailerHelper

  def task_creation(recipient, task)
    recipients recipient_email(recipient)
    from       from_email(task.creator)
    subject    task_subject(task)
    body       :task => task, :recipient => recipient
  end

  def new_comment(recipient, task, comment)
    recipients recipient_email(recipient)
    from       from_email(comment.author)
    subject    task_subject(task)
    body       :comment => comment, :task => task
  end

  def task_completion(recipient, task)
    recipients recipient_email(recipient)
    from       task_editor_email(task)
    subject    task_subject(task)
    body       :task => task
  end

  def assignee_id_edit(recipient, task, edit)
    recipients recipient_email(recipient)
    from       from_email(edit.editor)
    subject    task_subject(edit.task)
    body       :edit => edit
  end

  def due_date_edit(recipient, task, edit)
    recipients recipient_email(recipient)
    from       from_email(edit.editor)
    subject    task_subject(edit.task)
    body       :edit => edit
  end

  def estimate_edit(recipient, task, edit)
    recipients recipient_email(recipient)
    from       from_email(edit.editor)
    subject    task_subject(edit.task)
    body       :edit => edit
  end

  private
  
  def task_subject(task)
    "(##{task.id}) #{task.title}"
  end

  def task_editor_email(task)
    task.editor ? from_email(task.editor) : FROM_EMAIL_WITH_NAME
  end
end
