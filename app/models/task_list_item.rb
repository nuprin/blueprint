class TaskListItem < ActiveRecord::Base
                         # THESE MUST ALL BE SINGLE QUOTES
  acts_as_list :scope => ['context_id=#{context_id}',
                          'context_type=\'#{context_type}\''].join(' and ')

  belongs_to :task
  belongs_to :context, :polymorphic => true

  validates_presence_of :task
  validates_presence_of :context

end
