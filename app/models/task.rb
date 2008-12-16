class Task < ActiveRecord::Base
  KINDS = ["bug", "experiment", "stats"]

  belongs_to :project
  belongs_to :creator, :class_name => 'User'
  belongs_to :assignee, :class_name => 'User'

  has_many :comments
  has_many :list_items, :class_name => 'TaskListItem'

  named_scope :assigned_to, lambda{|user| {
    :conditions => {:assignee_id => user.id}
  }}
  
  named_scope :completed_today,
    :conditions => ["completed_at >= ?",
      (Time.now - 6.hours).at_midnight.getutc + 6.hours]

  named_scope :recently_completed, :order => "completed_at DESC"

  validates_presence_of :creator

  validates_numericality_of :estimate, :less_than_or_equal_to => 20,
                                       :allow_nil => true

  validates_length_of :title, :in => 1...255
  validates_length_of :description, :maximum => 5000, :allow_nil => true

  def completed?
    self.status == "completed"
  end

  def parked?
    self.status == "parked"
  end
  
  def prioritized?
    self.status == "prioritized"
  end

  def complete!
    self.status = "completed"
    self.completed_at = Time.now.getutc
    self.list_items.map(&:destroy)
    self.save!
  end

  def park!
    self.status = "parked"
    self.list_items.map(&:destroy)
    self.save!
  end

  def prioritize!
    self.undo_complete!
  end
  
  def undo_complete!
    self.status = "prioritized"
    self.completed_at = nil
    self.save!
    self.add_to_lists
  end

  def add_to_lists
    self.project.add_to_list(self) if self.project_id
    self.assignee.add_to_list(self) if self.assignee_id
  end

  before_save do |task|
    # Do the right thing when it comes to year boundaries.
    if task.due_date
      if task.due_date > Date.today + 1.year
        task.due_date -= 1.year
      end
      if task.due_date < Date.today
        task.due_date += 1.year
      end
    end
  end

  after_create do |task|
    if task.prioritized?
      task.add_to_lists
    end
  end

  after_destroy do |task|
    task.list_items.destroy_all
  end
end
