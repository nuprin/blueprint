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
    insert_at(pos)

    if other_item
      case context
      when User: sync_project_list
      when Project: sync_assignee_list
      end
    end
  end

  def sync_project_list
    return unless context_type == 'User'

    other_item.move_to_bottom && return if last?

    my_list = self.class.for_context(context).after(position).with_tasks.
                         all(:order => :position)

    next_in_project = my_list.find do |i|
      i.task.project_id == self.task.project_id
    end

    other_item.insert_at(next_in_project.other_item.position)
  end

  def sync_assignee_list
    return unless context_type == 'Project'
    other_item.move_to_bottom && return if last?
    other_item.insert_at(lower_item.other_item.position)
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
