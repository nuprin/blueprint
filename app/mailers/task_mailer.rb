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
    #TODO
    #this should add the "+id" to the email address that can then be parsed out?
    #reply_to   "philbot+#{task.id}@project-agape.com"
    reply_to   "philbot@project-agape.com"
    body       :comment => comment, :task => task
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

  def status_edit(recipient, task, edit)
    recipients recipient_email(recipient)
    from       from_email(edit.editor)
    subject    task_subject(edit.task)
    body       :edit => edit
  end

  def description_edit(recipient, task, edit)
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
