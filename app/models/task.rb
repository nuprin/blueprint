class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :creator, :class_name => 'User'
  belongs_to :assignee, :class_name => 'User'

  has_many :list_items, :class_name => 'TaskListItem'

  validates_presence_of :creator

  validates_numericality_of :estimate, :less_than_or_equal_to => 20,
                                       :allow_nil => true

  validates_length_of :title, :in => 1...255
  validates_length_of :description, :maximum => 5000, :allow_nil => true

  def completed?
    self.status == "completed"
  end

  def complete!
    self.status = "completed"
    self.completed_at = Time.now.getutc
    self.list_items.map(&:destroy)
    self.save!
  end

  after_create do |task|
    task.project.add_to_list(task) if task.project
    task.assignee.add_to_list(task) if task.assignee
  end

  after_destroy do |task|
    task.list_items.destroy_all
  end
end
