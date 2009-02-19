class Initiative < ActiveRecord::Base
  is_indexed :fields => [:title, :mission]

  set_table_name :projects

  belongs_to :category, :class_name => "ProjectCategory"

  has_many :tasks, :foreign_key => :project_id

  has_many :deliverables,
    :foreign_key => :project_id,
    :class_name => "Task",
    :conditions => {:type => "Deliverable"}

  named_scope :active,   :conditions => {:status => "active"}
  named_scope :inactive, :conditions => "status != 'active'",
    :order => "title ASC"

  def category_name
    self.category_id ? self.category.name : "Uncategorized"
  end
end
