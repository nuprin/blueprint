class User < ActiveRecord::Base
  has_many :task_list, :class_name => 'TaskListItem',
                       :as => :context,
                       :order => :position
  has_many :tasks
  has_many :completed_tasks, :class_name  => 'Task',
                             :conditions  => "completed_at IS NOT NULL",
                             :order       => "completed_at DESC",
                             :foreign_key => :assignee_id

  validates_length_of :name, :in => 1...50
  validates_numericality_of :fbuid, :allow_nil => true

  def add_to_list(task)
    TaskListItem.create!(:task => task, :context => self)
  end

  def real?
    !self.id.nil?
  end

  def self.form_options
    self.all.map{|u| [u.id, u.name]}.map do |(id, name)|
      "<option value=\"#{id}\">#{name}</option>"
    end.join
  end
end
