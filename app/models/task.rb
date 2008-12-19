class Task < ActiveRecord::Base
  KINDS = ["bug", "design", "experiment", "feature", "spec", "stats"]

  belongs_to :project
  belongs_to :creator, :class_name => 'User'
  belongs_to :assignee, :class_name => 'User'

  has_one :spec
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
  named_scope :for_project, lambda{|project| {
    :conditions => {:project_id => project.id}
  }}
  named_scope :parked, :conditions => {:status => "parked"}
  named_scope :recently_completed, :order => "completed_at DESC"
  named_scope :recently_updated, :order => "updated_at DESC"
  named_scope :with_details, :include => [:assignee, :project]


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

  def subscribed_users
    self.task_subscriptions.map(&:user).compact.uniq
  end

  def subscribed_user_names
    self.subscribed_users.map(&:name).to_sentence
  end

  before_save :adjust_year, :update_lists

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
      # TODO [chris]: :( This should not pull from the database.
      old_task = Task.find(self.id)
      if old_task.project_id != self.project_id
        old_task.project.remove_from_list(old_task) if old_task.project_id
        self.project.add_to_list(self) if self.project_id
      end
      if old_task.assignee_id != self.assignee_id
        old_task.assignee.remove_from_list(old_task) if old_task.assignee_id
        self.assignee.add_to_list(self) if self.assignee_id
      end
    end
    true
  end

  after_create do |task|
    if task.prioritized?
      task.add_to_lists
      if task.assignee_id && !(task.assignee_id == task.creator_id)
        TaskMailer.deliver_task_creation(task.assignee, task)
      end
    end
    TaskSubscription.create(:user => task.creator, :task => task)
  end

  def send_creation_email_to_subscribers
    if self.prioritized?
      list = self.subscribed_users
      list.delete(self.creator)
      list.each do |sub|
        TaskMailer.deliver_task_creation(sub, self)
      end
    end
  end

  after_destroy do |task|
    task.list_items.destroy_all
  end
end
