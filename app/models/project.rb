class Project < ActiveRecord::Base
  has_many :task_list, :class_name => 'TaskListItem',
                       :as         => :context,
                       :order      => :position

  has_many :tasks
  has_many :completed_tasks, :class_name => 'Task',
                             :conditions => "completed_at IS NOT NULL",
                             :order      => "completed_at DESC"

  has_many :parked_tasks, :class_name  => "Task",
                          :conditions  => "status = 'parked'",
                          :order       => "updated_at DESC"

  named_scope :active, :conditions => {:status => "active"},
                       :order => "title ASC"

  validates_length_of :title, :in => 1...255
  validates_length_of :description, :maximum => 5000, :allow_nil => true

  def active?
    self.status == "active"
  end

  def add_to_list(task)
    TaskListItem.create!(:task => task, :context => self)
  end

  def self.sorted
    self.all.sort_by(&:title)
  end

  def self.all_for_select
    self.sorted.map{|p| [p.title, p.id]}
  end
  
  after_destroy do |project|
    project.tasks.destroy_all
  end
end
