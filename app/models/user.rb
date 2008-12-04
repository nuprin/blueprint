class User < ActiveRecord::Base
  has_many :task_list, :class_name => 'TaskListItem',
                       :as => :context,
                       :order => :position
  has_many :tasks

  validates_length_of :name, :in => 1...50
  validates_numericality_of :fbuid, :allow_nil => true

  def add_to_list(task)
    TaskListItem.create!(:task => task, :context => self)
  end
end
