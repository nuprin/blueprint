class TaskMailer < ActionMailer::Base

  include MailerHelper
  include TaskMailerHelper

  REPLY_TO = "blueprint@causes.com"
  
  def task_creation(recipient, task)
    recipients recipient_email(recipient)
    from       from_email(task.creator)
    subject    task_subject(task)
    reply_to   REPLY_TO
    body       :task => task, :recipient => recipient
  end

  def new_comment(recipient, task, comment)
    recipients recipient_email(recipient)
    from       from_email(comment.author)
    subject    task_subject(task)
    #TODO
    #this should add the "+id" to the email address that can then be parsed out?
    #reply_to   "philbot+#{task.id}@project-agape.com"
    reply_to   REPLY_TO
    body       :comment => comment, :task => task
  end

  def assignee_id_edit(recipient, task, edit)
    recipients recipient_email(recipient)
    from       from_email(edit.editor)
    subject    task_subject(edit.task)
    reply_to   REPLY_TO
    body       :edit => edit
  end

  def due_date_edit(recipient, task, edit)
    recipients recipient_email(recipient)
    from       from_email(edit.editor)
    subject    task_subject(edit.task)
    reply_to   REPLY_TO
    body       :edit => edit
  end

  def estimate_edit(recipient, task, edit)
    recipients recipient_email(recipient)
    from       from_email(edit.editor)
    subject    task_subject(edit.task)
    reply_to   REPLY_TO
    body       :edit => edit
  end

  def status_edit(recipient, task, edit)
    recipients recipient_email(recipient)
    from       from_email(edit.editor)
    subject    task_subject(edit.task)
    reply_to   REPLY_TO
    body       :edit => edit
  end

  def description_edit(recipient, task, edit)
    recipients recipient_email(recipient)
    from       from_email(edit.editor)
    subject    task_subject(edit.task)
    reply_to   REPLY_TO
    body       :edit => edit
  end

  def new_subscription(subscription, editor)
    recipients recipient_email(subscription.user)
    from       from_email(editor)
    subject    task_subject(subscription.task)
    reply_to   REPLY_TO
    body       :editor => editor, :task => subscription.task
  end

  private
  
  def task_subject(task)
    # TODO [chris]: Remove after there's little activity for tasks created
    # before this date.
    if task.created_at >= Time.parse("January 15, 2009 11:00:00").getutc
      "(Blueprint ##{task.id}) #{task.title}"
    else
      "(##{task.id}) #{task.title}"      
    end
  end

  def task_editor_email(task)
    task.editor ? from_email(task.editor) : FROM_EMAIL_WITH_NAME
  end
end
