class TaskListItem < ActiveRecord::Base
  acts_as_list

  belongs_to :task
  belongs_to :context, :polymorphic => true

  validates_presence_of :task
  validates_presence_of :context
  validates_numericality_of :position
end
