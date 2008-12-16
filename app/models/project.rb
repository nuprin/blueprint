class Project < ActiveRecord::Base
  has_many :task_list, :class_name => 'TaskListItem',
                       :as         => :context,
                       :order      => :position

  has_many :tasks

  has_one :spec

  named_scope :active, :conditions => {:status => "active"},
                       :order => "title ASC"

  validates_length_of :title, :in => 1...255
  validates_length_of :description, :maximum => 5000, :allow_nil => true

  def completed_tasks
    Task.completed.recently_completed.for_project(self).with_details
  end

  def parked_tasks
    Task.parked.recently_updated.for_project(self).with_details
  end

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

  after_create do |project|
    Spec.create(:project_id => project.id)
  end

  after_destroy do |project|
    project.tasks.destroy_all
  end
end
