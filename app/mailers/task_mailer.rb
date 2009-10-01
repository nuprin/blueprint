class TaskMailer < ActionMailer::Base

  include MailerHelper
  include TaskMailerHelper
  helper ApplicationHelper

  REPLY_TO = EMAIL_REPLY_TO
  
  def task_creation(recipient, task)
    recipients recipient_email(recipient)
    from       from_email(task.creator)
    subject    task_subject(task)
    reply_to   REPLY_TO
    maybe_attach_image(task)
    part :content_type => "text/plain",
         :body =>
            render_message("task_creation", :task => task,
              :recipient => recipient)

  end

  def new_comment(recipient, task, comment)
    recipients recipient_email(recipient)
    from       from_email(comment.author)
    subject    task_subject(task)
    reply_to   REPLY_TO
    maybe_attach_image(comment)
    part :content_type => "text/plain",
         :body =>
            render_message("new_comment", :comment => comment, :task => task)
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

  def recent_edits(recipient, task, edits)
    recipients   recipient_email(recipient)
    from         FROM_EMAIL_WITH_NAME
    subject      task_subject(task)
    reply_to     REPLY_TO
    content_type "text/html"
    body         :task => task, :edits => edits
  end

  private

  def maybe_attach_image(attachable)
    if attachable.image.exists?
      attachment :content_type => attachment.image_content_type,
                 :body         => File.read(attachable.image.path)
    end
  end

  def task_subject(task)
    "(Blueprint ##{task.id}) #{task.title}"
  end

  def task_editor_email(task)
    task.editor ? from_email(task.editor) : FROM_EMAIL_WITH_NAME
  end
end
