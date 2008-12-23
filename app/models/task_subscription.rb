class TaskSubscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  validates_presence_of :user
  validates_presence_of :task
  validates_uniqueness_of :user_id, :scope => [:task_id]  

  module UserMethods
    # An idempotent operation that ensures that the user will be subscribed
    # to all updates about the relevant task.
    def subscribe_to(task)
      task.task_subscriptions.create(:user_id => self.id)
    end
  end

end
