class Project < ActiveRecord::Base
  belongs_to :category, :class_name => "ProjectCategory"
  belongs_to :feature

  has_many :assignees, :through => :tasks,
                       :uniq    => true,
                       :order   => :name
  has_many :comments, :as        => :commentable,
                      :dependent => :destroy
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

  named_scope :followed_by, lambda { |user| {
    :conditions => {:id => user.subscribed_project_ids}
  }}
  named_scope :for_category, lambda { |category_id| {
    :conditions => {:category_id => category_id}
  }}
  named_scope :inactive, :conditions => {:status => "inactive"},
                         :order => "title ASC"
  named_scope :uncategorized, :conditions => {:category_id => nil}

  validates_length_of :title, :in => 1...255
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

  def estimate
    self.tasks.sum(:estimate) || 0
  end

  def self.sorted
    self.all.sort_by(&:title)
  end

  def self.all_for_select
    self.active.map{|p| [p.title, p.id]}
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

  before_save do |project|
    category = ProjectCategory.find_by_id(project.category_id)
    if project.status_changed? && project.category_id
      if project.active?
        category.add_to_list(project)
      else
        category.remove_from_list(project)
      end
    end
    if project.category_id_changed?
      if project.category_id_was
        old_category = ProjectCategory.find(project.category_id_was)
        old_category.remove_from_list(project)
      end
      if project.category_id
        category.add_to_list(project)
      end
    end
  end

  after_create do |project|
    Specification.create(:project_id => project.id)
  end

  after_save do |project|
    if ["Product", "Engineering"].include?(project.category_name)
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
