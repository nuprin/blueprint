class TaskListItem < ActiveRecord::Base
                         # THESE MUST ALL BE SINGLE QUOTES
  acts_as_list :scope => ['context_id=#{context_id}',
                          'context_type=\'#{context_type}\''].join(' and ')

  belongs_to :task
  belongs_to :context, :polymorphic => true

  validate :cannot_be_subtask
  validates_presence_of :task
  validates_presence_of :context

  validates_uniqueness_of :task_id, :scope => [:context_id, :context_type],
    :message => "cannot be added twice to the same task list"
  
  named_scope(:for_context, lambda do |context|
    {:conditions => {:context_type => context.class.name,
                     :context_id   => context.id}}
  end)

  def cannot_be_subtask
    if self.task.parent_id
      errors.add_to_base("cannot be a subtask")
    end
  end

  before_validation do |item|
    # Only add tasks to lists that have not been completed.
    !item.task.completed?
  end

end
