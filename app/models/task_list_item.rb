class TaskListItem < ActiveRecord::Base
                         # THESE MUST ALL BE SINGLE QUOTES
  acts_as_list :scope => ['context_id=#{context_id}',
                          'context_type=\'#{context_type}\''].join(' and ')

  belongs_to :task
  belongs_to :context, :polymorphic => true

  validates_presence_of :task
  validates_presence_of :context

  named_scope :with_tasks, :include => :task
  named_scope :with_contexts, :include => :context
  named_scope(:for_context, lambda do |context|
    {:conditions => {:context_type => context.class.name,
                     :context_id   => context.id}}
  end)
  named_scope(:after, lambda do |position|
    {:conditions => "position > #{position}"}
  end)

  def update_position(pos)
    return if pos == position

    insert_at(pos)

    if other_item && other_item.list.size > 1
      other_item.update_contextual_position(contextual_position)
    end
  end

  def update_contextual_position(pos)
    return if contextual_position == pos
    moving_up = pos < contextual_position

    remove_from_list
    if moving_up
      insert_at(contextual_item_at(pos).position)
    else
      clear_list
      insert_at(contextual_item_at(pos).position + 1)
    end
  end

  def list
    @list ||=
      self.class.for_context(context).with_tasks.all(:order => :position)
  end
  def clear_list
    @list = nil
  end

  def contextual_list
    list.select do |i|
      i.task.send(other_context_method) == other_context
    end
  end

  def contextual_position
    # Maintain 1-based indexing
    contextual_list.index(self) + 1
  end

  def contextual_item_at(pos)
    # pos is 1-based
    contextual_list[pos-1]
  end
protected

  # Returns the item containing the same task in the other (Project/User) list
  def other_item
    return @other_item.first if @other_item
    other = other_context.task_list.with_tasks.all.find do |item|
      item.task == task
    end if other_context
    (@other_item = [other]).first
  end

private

  def other_context
    (@other_context ||= [task.send(other_context_method)]).first
  end

  def other_context_method
    case context_type
    when 'User': :project
    when 'Project': :assignee
    end
  end
end
