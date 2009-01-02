class User < ActiveRecord::Base

  has_many :created_tasks,
    :class_name  => "Task",
    :foreign_key => "creator_id",
    :order       => "id DESC",
    :include     => [:assignee, :project]

  has_many :subscribed_tasks, :through => :subscriptions,
                              :source  => :task,
                              :order   => "tasks.id DESC",
                              :include => [:assignee, :project]

  has_many :task_list, :class_name => 'TaskListItem',
                       :as => :context,
                       :order => :position
  has_many :tasks
  has_many :task_subscriptions, :conditions => {:entity_type => "Task"},
    :class_name => "Subscription"

  validates_length_of :name, :in => 1...50

  include Subscription::UserMethods

  def parked_tasks
    Task.parked.recently_updated.assigned_to(self).with_details
  end

  def completed_tasks_today
    Task.assigned_to(self).completed_today.recently_completed.with_details
  end

  def self.form_options
    self.all.map{|u| [u.id, u.name]}.map do |(id, name)|
      "<option value=\"#{id}\">#{name}</option>"
    end.join
  end

  def self.sorted
    self.all.sort_by(&:name)
  end

  def add_to_list(task)
    TaskListItem.create!(:task => task, :context => self)
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
