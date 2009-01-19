class User < ActiveRecord::Base

  has_many :created_tasks,
    :class_name  => "Task",
    :foreign_key => "creator_id",
    :order       => "id DESC",
    :include     => [:assignee, :project]

  has_many :project_subscriptions, :conditions => {:entity_type => "Project"},
    :class_name => "Subscription"
 
  has_many :subscribed_projects, :through => :project_subscriptions,
    :source => :project,
    :conditions => "subscriptions.entity_type = 'Project'",
    :order => "title ASC"

  has_many :subscribed_tasks, :through => :task_subscriptions,
    :source  => :task,
    :conditions => "subscriptions.entity_type = 'Task'",
    :order   => "tasks.id DESC",
    :include => [:assignee, :project]

  has_many :task_list, :class_name => 'TaskListItem',
                       :as => :context,
                       :order => :position
  has_many :tasks, :foreign_key => :assignee_id
  has_many :task_subscriptions, :conditions => {:entity_type => "Task"},
    :class_name => "Subscription"

  named_scope :active, :conditions => {:active => true}

  validates_length_of :name, :in => 1...50

  include Subscription::UserMethods
  include Task::UserMethods

  def parked_tasks
    Task.parked.recently_updated.assigned_to(self).with_details
  end

  def completed_tasks_today
    Task.assigned_to(self).completed_today.recently_completed.with_details
  end

  def self.form_options
    self.sorted.map{|u| [u.id, u.name]}.map do |(id, name)|
      "<option value=\"#{id}\">#{name}</option>"
    end.join
  end

  def self.sorted
    self.active.sort_by(&:name)
  end

  def add_to_list(task)
    TaskListItem.create(:task => task, :context => self)
  end

  def remove_from_list(task)
    TaskListItem.destroy_all :task_id => task, :context_id => self.id,
                             :context_type => self.class.name
  end

  def current_task
    task_list_item = self.task_list.first
    task_list_item ? task_list_item.task : nil
  end

  def real?
    !self.id.nil?
  end

end
