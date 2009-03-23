class ProjectListItem < ActiveRecord::Base
  acts_as_list :scope => :category

  belongs_to :category, :class_name => "ProjectCategory"
  belongs_to :project
  
  validates_presence_of :category
  validates_presence_of :project

  validates_uniqueness_of :project_id, :scope => :category_id
end
