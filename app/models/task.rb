class Task < ActiveRecord::Base
  is_indexed :fields => [:title, :description]

  KINDS = [
    "bug", "copy", "design", "estimate", "experiment", "feature", "inquiry", 
    "spec", "stats"
  ]

  CURRENT_RANGE = [
    Time.now.at_beginning_of_week, 1.week.from_now.at_end_of_week
  ].map(&:to_date)

  attr_accessor :editor

  belongs_to :assignee, :class_name => 'User'
  belongs_to :creator, :class_name => 'User'
  belongs_to :feature
  belongs_to :parent, :class_name => "Task"
  belongs_to :project

  has_one :deferred_task
  has_one :specification

  has_many :children, :foreign_key => :parent_id, :class_name => "Task"
  has_many :comments, :as => "commentable"
  has_many :list_items, :class_name => 'TaskListItem'
  has_many :subscribed_users, :through => :subscriptions, :source => :user,
    :uniq => true
  has_many :subscriptions, :as => "entity"
  has_many :task_edits

  named_scope :assigned_to, lambda{|user| {
    :conditions => {:assignee_id => user.id}
  }}
  named_scope :assigned_to_other, :conditions => "creator_id != assignee_id"
  named_scope :bugs, :conditions => {:kind => "bug"}
  named_scope :completed_today, lambda {{
    :conditions => ["completed_at >= ?",
      (Time.now - 6.hours).at_midnight.getutc]
  }}
  named_scope :completed, :conditions => {:status => "completed"}
  named_scope :completed_since, lambda {|since| {
    :conditions => {:completed_at => Range.new(since.getutc, Time.now.getutc)}
  }}
  named_scope :for_project, lambda{|project| {
    :conditions => {:project_id => project.id}
  }}
  named_scope :parked, :conditions => {:status => "parked"},
    :order => "updated_at DESC"
  named_scope :prioritized, :conditions => {:status => "prioritized"}
  named_scope :recently_completed, :order => "completed_at DESC"
  named_scope :recently_updated, :order => "updated_at DESC"
  named_scope :undescribed, :conditions => {:description => ''}
  named_scope :with_due_date, :conditions => "due_date IS NOT NULL"
  named_scope :with_details, :include => [:assignee, :project]
  named_scope :with_deferred_tasks, :include => :deferred_task

  validates_presence_of :creator

  validates_numericality_of :estimate, :less_than_or_equal_to => 20,
                                       :allow_nil => true

  validates_length_of :title, :in => 1...255
  validates_length_of :description, :maximum => MAX_BODY_SIZE, :allow_nil => true

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

  def due_soon?
    self.due_today? || self.due_tomorrow?
  end

  def overdue?
    self.due_date && (Date.today > self.due_date)
  end

  def due_tomorrow?
    Date.tomorrow == self.due_date
  end

  def due_today?
    Date.today == self.due_date
  end

  def complete!
    self.status = "completed"
    self.completed_at = Time.now.getutc
    self.save!
    self.send_later(:tell_campfire) if Rails.env == "production"
  end

  def tell_campfire
    project = self.project_id ? " (#{self.project.title})" : ""
    Campfire.speak <<-HTML
      #{self.editor.name} marked
      "#{self.title}" complete. http://blueprint/tasks/#{self.id}#{project}
    HTML
  end

  def park!
    self.status = "parked"
    self.save!
  end

  def prioritize!
    self.deferred_task.destroy if self.deferred_task
    self.undo_complete!
  end
  
  def undo_complete!
    self.status = "prioritized"
    self.completed_at = nil
    self.save!
  end

  def add_to_lists
    self.project.add_to_list(self) if self.project_id
    self.assignee.add_to_list(self) if self.assignee_id
  end

  def unsubscribed_users
    (User.active - subscribed_users).sort_by(&:name)
  end

  def subscribed_user_names
    self.subscribed_users.map(&:name).to_sentence
  end
  
  def comments_and_edits
    (self.task_edits + self.comments).sort_by(&:created_at)
  end
  
  def self.prioritize_due_tasks
    self.parked.with_due_date.each do |task|
      if task.due_soon? || task.overdue?
        task.editor = User.butler
        task.prioritize!
      end
    end
  end

  before_create :set_already_completed
  before_save :adjust_year, :update_lists, :set_type, :check_reassignment
  before_update :record_changes

  # We need to check reassignment before and after saving to account for
  # reassignment and a new task creation, respectively. There probably is a
  # cleaner way to do this.
  after_save :check_reassignment

  def set_already_completed
    self.completed_at = Time.now.getutc if completed?
  end

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
      if self.due_date > (Date.today + 1.year)
        self.due_date -= 1.year
      end
      if self.due_date < (Date.today - 6.months)
        self.due_date += 1.year
      end
    end
  end

  def update_lists
    # TODO: This can be encapsulated in before_update.
    if !self.new_record?
      old_task = Task.find(self.id)
      if self.project_id_changed?
        old_task.project.remove_from_list(old_task) if self.project_id_was
        self.project.add_to_list(self) if self.project_id
      end
      if self.assignee_id_changed?
        old_task.assignee.remove_from_list(old_task) if self.assignee_id_was
        self.assignee.add_to_list(self) if self.assignee_id
      end
      if self.status_changed?
        if ["completed", "parked"].include?(self.status)
          self.list_items.destroy_all
        elsif self.status == "prioritized"
          self.add_to_lists
        end
      end
    end
    true
  end

  def mass_mailer
    MassMailer.new(self)
  end

  def displayed_type
    self.is_a?(Deliverable) ? "Deliverable" : "Task"
  end

  def completion_day
    (self.completed_at.getlocal - 6.hours).at_midnight.to_date
  end

  after_create do |task|
    task.creator.subscribe_to(task)
    # Temporarily subscribe Michel to tasks assigned to engineers.
    if task.assignee_id && task.assignee.engineer? && User.michel
      User.michel.subscribe_to(task)
    end
    if task.prioritized?
      task.add_to_lists
    end
  end

  after_save do |task|
    if task.assignee_id && task.project_id
      task.assignee.subscribe_to(task.project)
    end
    if task.kind == "bug"
      Bug.add_to_bug_task_list(task)
    else
      Bug.remove_from_bug_task_list(task)      
    end
  end

  after_destroy do |task|
    task.list_items.destroy_all
  end
  
  def check_reassignment
    if self.assignee_id
      self.assignee.subscribe_to(self)
    end
  end

  def self.sorted_assignees(tasks)
    assignee_ids = tasks.map(&:assignee_id).compact.uniq
    User.find(assignee_ids).sort_by(&:name)
  end
  
  module UserMethods
    def tasks_completed_by_day(since = 7.days.ago)
      range = [since, Time.now.getutc]
      conditions = {:completed_at => Range.new(*range), :assignee_id => self.id}
      tasks = Task.all(:conditions => conditions)
      tasks.group_by(&:completion_day).sort_by(&:first).reverse    
    end
  end
end
