class Subscription < ActiveRecord::Base
  belongs_to :entity, :polymorphic => true
  belongs_to :project, :foreign_key => "entity_id"
  belongs_to :task,    :foreign_key => "entity_id"
  belongs_to :user

  validates_presence_of :user
  validates_presence_of :entity

  validates_uniqueness_of :user_id, :scope => [:entity_id, :entity_type]

  module UserMethods
    # An idempotent operation that ensures that the user will be subscribed
    # to all updates about the relevant task.
    def subscribe_to(entity)
      entity.subscriptions.create(:user_id => self.id)
    end
  end

end
