class Project < ActiveRecord::Base
  has_many :task_list, :class_name => 'TaskListItem',
                       :as => :context,
                       :order => :position
  has_many :tasks

  validates_length_of :title, :in => 1...255
  validates_length_of :description, :maximum => 5000, :allow_nil => true

  def add_to_list(task)
    TaskListItem.create!(:task => task, :context => self)
  end

  after_destroy do |project|
    project.tasks.destroy_all
  end
end
