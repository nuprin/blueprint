class Task < ActiveRecord::Base
  KINDS = ["bug", "design", "experiment", "feature", "inquiry", "spec", "stats"]

  CURRENT_RANGE = [
    Time.now.at_beginning_of_week, 1.week.from_now.at_end_of_week
  ].map(&:to_date)

  attr_accessor :editor

  belongs_to :project
  belongs_to :creator, :class_name => 'User'
  belongs_to :assignee, :class_name => 'User'
  belongs_to :parent, :class_name => "Task"

  has_one :specification
  has_many :children, :foreign_key => :parent_id, :class_name => "Task"
  has_many :comments
  has_many :task_subscriptions
  has_many :list_items, :class_name => 'TaskListItem'

  named_scope :assigned_to, lambda{|user| {
    :conditions => {:assignee_id => user.id}
  }}
  named_scope :completed_today,
    :conditions => ["completed_at >= ?",
      (Time.now - 6.hours).at_midnight.getutc]
  named_scope :completed, :conditions => {:status => "completed"}
  named_scope :currently_due, lambda{|range| {
    :conditions => {:due_date => Range.new(*CURRENT_RANGE)}
  }}
  named_scope :for_project, lambda{|project| {
    :conditions => {:project_id => project.id}
  }}
  named_scope :parked, :conditions => {:status => "parked"}
  named_scope :recently_completed, :order => "completed_at DESC"
  named_scope :recently_updated, :order => "updated_at DESC"
  named_scope :with_due_date, :conditions => "due_date IS NOT NULL"
  named_scope :with_details, :include => [:assignee, :project]


  validates_presence_of :creator

  validates_numericality_of :estimate, :less_than_or_equal_to => 20,
                                       :allow_nil => true

  validates_length_of :title, :in => 1...255
  validates_length_of :description, :maximum => 5000, :allow_nil => true

  indexes_columns :title, :description, :using => :ferret

  def to_s
    title
  end

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
    self.mass_mailer.ignoring(self.assignee).deliver_task_completion
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

  def subscribed_users
    self.task_subscriptions.map(&:user).compact.uniq
  end

  def unsubscribed_users
    (User.all - subscribed_users).sort_by(&:name)
  end

  def subscribed_user_names
    self.subscribed_users.map(&:name).to_sentence
  end

  before_save :adjust_year, :update_lists, :set_type, :notify_subscribers

  before_update :record_changes

  def record_changes
    TaskEdit.record_changes!(self)
  end

  def set_type
    if self.parent_id
      self.type = "SubTask"
    end
  end

  def adjust_year
    # Do the right thing when it comes to year boundaries.
    if self.due_date
      if self.due_date > Date.today + 1.year
        self.due_date -= 1.year
      end
      if self.due_date < Date.today
        self.due_date += 1.year
      end
    end
  end

  def update_lists
    unless self.new_record?
      old_task = Task.find(self.id)
      if self.project_id_changed?
        old_task.project.remove_from_list(old_task) if self.project_id_was
        self.project.add_to_list(self) if self.project_id
      end
      if self.assignee_id_changed?
        old_task.assignee.remove_from_list(old_task) if self.assignee_id_was
        self.assignee.add_to_list(self) if self.assignee_id
      end
    end
    true
  end

  def notify_subscribers
    if self.assignee_id_changed?
      self.mass_mailer.deliver_task_reassignment
    end
    if self.due_date_changed?
      self.mass_mailer.deliver_task_due_date_changed
    end
  end

  def self.create_with_subscriptions!(task_params, cc_ids)
    task = self.create!(task_params)
    cc_ids.each do |cc_id|
      task.task_subscriptions.create(:user_id => cc_id)
    end
    task.mass_mailer.ignoring(task.creator).deliver_task_creation
    task
  end
  
  def mass_mailer
    MassMailer.new(self)
  end

  after_create do |task|
    if task.assignee_id
      task.assignee.subscribe_to(task)
    end
    task.creator.subscribe_to(task)
    if task.prioritized?
      task.add_to_lists
    end
  end

  after_destroy do |task|
    task.list_items.destroy_all
  end
end
