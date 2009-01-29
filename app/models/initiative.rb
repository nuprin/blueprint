class Initiative < ActiveRecord::Base
  set_table_name :projects

  has_many :tasks, :foreign_key => :project_id

  has_many :deliverables,
    :foreign_key => :project_id,
    :class_name => "Task",
    :conditions => {:type => "Deliverable"}

  named_scope :active,   :conditions => {:status => "active"}
  named_scope :inactive, :conditions => "status != 'active'",
    :order => "title ASC"
end
