class ProjectListItem < ActiveRecord::Base
  acts_as_list :scope => :category

  belongs_to :category, :class_name => "ProjectCategory"
  belongs_to :project
end
