class MassMailer
  attr_reader :ignored_users, :task

  def initialize(task)
    @task = task
    @ignored_users = []
  end
  
  def ignoring(users)
    @ignored_users = [users].flatten
    self
  end
  
  def recipients
    @task.subscribed_users - @ignored_users
  end

  def method_missing(method, *args)
    recipients.each do |recipient|
      TaskMailer.send(method, recipient, @task, *args)
    end
  end
end
