class TaskMailer < ActionMailer::Base

  def task_creation(recipient, task)
    recipients recipient_email(recipient)
    from       "blueprint@causes.com"
    type = task.kind.empty? ? 'task' : task.kind
    if task.assignee== recipient
      subject "You have a new #{type}: '#{task.title}'"
    else
      subject "A new #{type} has been assigned to #{task.assignee.name}"
    end
    body :task => task
  end

  def task_comment(recipient, comment)
    recipients recipient_email(recipient)
    from       "blueprint@causes.com"
    task = comment.task
    type = task.kind.empty? ? 'task' : task.kind
    if task.assignee == recipient
      subject "#{comment.author.name} commented on your #{type}, '#{task.title}'"
    else
      subject "#{comment.author.name} commented on #{task.assignee.name}'s" +
              " #{type}, '#{task.title}'"
    end
    content_type 'text/html'
    body :comment => comment
  end

  def task_duedate_changed(recipient, task)
    recipients recipient_email(recipient)
    from       "blueprint@causes.com"
    type = task.kind.empty? ? 'task' : task.kind
    #Do we want to include the new duedate in the subject?
    content_type 'text/html'
    subject "The due date has changed on your #{type}, '#{task.title}'"
    body :task
  end
  
  def task_reassigned(recipient, task)
    recipients recipient_email(recipient)
    from       "blueprint@causes.com"
    type = task.kind.empty? ? 'task' : task.kind
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
  def recipient_email(recipient)
    "#{recipient.name} <#{recipient.email}>"
  end

end
