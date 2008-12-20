class TaskMailer < ActionMailer::Base

  include TaskMailerHelper

  FROM_EMAIL           = "blueprint@causes.com"
  FROM_EMAIL_WITH_NAME = "Blueprint <#{FROM_EMAIL}>"

  default_url_options[:host] = HOST

  def task_creation(recipient, task)
    recipients recipient_email(recipient)
    from       FROM_EMAIL_WITH_NAME
    subject    task_subject(task)
    body       :task => task, :recipient => recipient
  end

  def task_comment(recipient, comment)
    recipients recipient_email(recipient)
    from       "#{comment.author.name} <#{FROM_EMAIL}>"
    subject    task_subject(comment.task)
    body       :comment => comment
  end

  def task_duedate_changed(recipient, task)
    recipients recipient_email(recipient)
    from       FROM_EMAIL_WITH_NAME
    type = task.kind.empty? ? 'task' : task.kind
    #Do we want to include the new duedate in the subject?
    content_type 'text/html'
    subject    task_subject(task)
    subject "The due date has changed on your #{type}, '#{task.title}'"
    body :task
  end
  
  def task_reassigned(recipient, task)
    recipients recipient_email(recipient)
    from       FROM_EMAIL_WITH_NAME
    type = task.kind.empty? ? 'task' : task.kind
    subject    task_subject(task)
    if task.assignee == recipient
      subject "A #{type} has been reassigned to you: '#{task.title}'"
    else
      subject "Your #{type} '#{task.title}' has been reassigned " +
              "to #{task.assignee.name}"
    end
    content_type 'text/html'
    body :task
  end

  private
  
  def task_subject(task)
    "(##{task.id}) #{task.title}"
  end

  def recipient_email(recipient)
    "#{recipient.name} <#{recipient.email}>"
  end

end
