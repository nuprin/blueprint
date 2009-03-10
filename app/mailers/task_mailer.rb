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
    reply_to   REPLY_TO
    if comment.image_file_name
      attachment :content_type => comment.image_content_type,
                 :body         => File.read(comment.image.path)
    end
    part :content_type => "text/plain",
         :body =>
            render_message("new_comment", :comment => comment, :task => task)
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

  def title_edit(recipient, task, edit)
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

  def task_deferred(recipient, task, deferred_task)
    recipients recipient_email(recipient)
    from       from_email(deferred_task.creator)
    subject    task_subject(task)
    reply_to   REPLY_TO
    body       :deferred_task => deferred_task
  end

  def task_reprioritized(recipient, task)
    recipients recipient_email(recipient)
    from       REPLY_TO
    subject    task_subject(task)
    reply_to   REPLY_TO
    body       :task => task
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
