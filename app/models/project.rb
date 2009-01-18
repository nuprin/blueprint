class Project < ActiveRecord::Base
  belongs_to :category, :class_name => "ProjectCategory"

  has_many :assignees, :through => :tasks, :uniq => true, :order => :name
  has_many :comments, :as => :commentable
  has_many :subscriptions, :as => :entity
  has_many :subscribed_users, :through => :subscriptions, :source => :user,
    :uniq => true
  has_many :task_list, :class_name => 'TaskListItem',
                       :as         => :context,
                       :order      => :position
  has_many :tasks

  has_one :specification

  named_scope :active, :conditions => {:status => "active"},
                       :order => "title ASC"

  named_scope :followed_by, lambda { |user| {
    :conditions => {:id => user.subscribed_project_ids}
  }}
  named_scope :for_category, lambda { |category_id| {
    :conditions => {:category_id => category_id}
  }}
  
  validates_length_of :title, :in => 1...255
  indexes_columns :title, :using => :ferret
  
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
    TaskListItem.create!(:task => task, :context => self)
  end

  def remove_from_list(task)
    TaskListItem.destroy_all :task_id => task, :context_id => self.id,
                             :context_type => self.class.name
  end

  def estimate
    self.tasks.sum(:estimate) || 0
  end

  def self.sorted
    self.all.sort_by(&:title)
  end

  def self.all_for_select
    self.sorted.map{|p| [p.title, p.id]}
  end
  
  def category_name
    self.category_id ? self.category.name : "Uncategorized"
  end

  def mass_mailer
    MassMailer.new(self)
  end

  def subscribed_user_names
    self.subscribed_users.map(&:name).to_sentence
  end

  after_create do |project|
    Specification.create(:project_id => project.id)
  end

  after_destroy do |project|
    project.tasks.destroy_all
  end
end
