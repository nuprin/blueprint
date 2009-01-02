class MassMailer
  attr_reader :ignored_users, :task_or_project

  def initialize(task_or_project)
    @task_or_project = task_or_project
    @ignored_users = []
  end
  
  def ignoring(users)
    @ignored_users = [users].flatten
    self
  end
  
  def recipients
    @task_or_project.subscribed_users(true) - @ignored_users
  end

  def mailer
    @task_or_project.is_a?(Task) ? TaskMailer : ProjectMailer
  end

  def method_missing(method, *args)
    recipients.each do |recipient|
      mailer.send(method, recipient, @task_or_project, *args)
    end
  end
end
