class Project < ActiveRecord::Base
  FORWARD_HOURS_PER_DAY = 5.5
  PHASES = [
    "Idea", "Spec", "Spec Review", "Estimate", "Coding", "Released",
    "Post-Release Tweaks", "Stats Collection"
  ]

  belongs_to :category, :class_name => "ProjectCategory"
  belongs_to :feature

  has_many :assignees, :through => :tasks,
                       :uniq    => true,
                       :order   => :name
  has_many :comments, :as        => :commentable,
                      :dependent => :destroy

  has_many :project_list_items, :dependent => :destroy

  has_many :subscriptions, :as        => :entity, 
                           :dependent => :destroy
  has_many :subscribed_users, :through => :subscriptions, 
                              :source  => :user,
                              :uniq    => true
  has_many :task_list, :class_name => 'TaskListItem',
                       :as         => :context,
                       :order      => :position,
                       :dependent  => :destroy
  has_many :tasks

  has_one :specification, :dependent => :destroy

  named_scope :active, :conditions => {:status => "active"},
                       :order => "title ASC"
  named_scope :completed, :conditions => {:status => "completed"}
  named_scope :followed_by, lambda { |user| {
    :conditions => {:id => user.subscribed_project_ids}
  }}
  named_scope :for_category, lambda { |category_id| {
    :conditions => {:category_id => category_id}
  }}
  named_scope :inactive, :conditions => {:status => "inactive"},
                         :order => "title ASC"

  validates_length_of :title, :in => 1...255
  validates_presence_of :category_id
  validates_uniqueness_of :title,
    :message => "is the same as another initiative. Try a different one?"
  
  def to_s
    self.title
  end

  def completed_tasks
    Task.completed.recently_completed.for_project(self).with_details
  end

  def completed_tasks_this_week
    Task.completed.recently_completed.completed_since(7.days.ago).
      for_project(self).with_details
  end

  def parked_tasks
    Task.parked.recently_updated.for_project(self).with_details
  end

  def active?
    self.status == "active"
  end

  def add_to_list(task)
    TaskListItem.create(:task => task, :context => self)
  end

  def remove_from_list(task)
    TaskListItem.destroy_all :task_id => task, :context_id => self.id,
                             :context_type => self.class.name
  end

  def days_left
    (self.tasks.prioritized.map(&:estimate).compact.sum /
     FORWARD_HOURS_PER_DAY).round(1)
  end

  def estimate
    self.tasks.sum(:estimate) || 0
  end

  def self.sorted
    self.all.sort_by(&:title)
  end

  def self.all_for_select
    self.active.map{|p| [p.title, p.id]}
  end
  
  def mass_mailer
    MassMailer.new(self)
  end

  def subscribed_user_names
    self.subscribed_users.map(&:name).to_sentence
  end

  def cleaned_spec_url
    self.spec_url = self.spec_url.strip
    if !self.spec_url.starts_with?('http://')
      'http://' + self.spec_url
    else
      self.spec_url
    end
  end

  def external_spec?
    !self.spec_url.blank?
  end

  before_save :refresh_category_lists
    
  def refresh_category_lists
    unless self.new_record?
      category = ProjectCategory.find_by_id(self.category_id)
      if self.status_changed? && self.category_id
        if self.active?
          category.add_to_list(self)
        else
          category.remove_from_list(self)
        end
      end
      if self.category_id_changed?
        if self.category_id_was
          old_category = ProjectCategory.find(self.category_id_was)
          old_category.remove_from_list(self)
        end
        if self.category_id
          category.add_to_list(self)
        end
      end
    end    
  end

  after_create do |project|
    Specification.create(:project_id => project.id)
    project.category.add_to_list(project)
  end

  after_save do |project|
    if "Product & Engineering" == project.category.name
      u = User.find_by_name("Michel")
      if u
        u.subscribe_to(project) 
      end
    end
  end

  before_destroy do |project|
    project.tasks.each do |task|
      task.update_attribute(:project_id, nil)
    end
  end
end
