class ProjectCategory < ActiveRecord::Base
  has_many :project_list, :class_name => "ProjectListItem", :order => :position,
    :foreign_key => :category_id
  has_many :projects, :foreign_key => :category_id
  named_scope :sorted, :order => "name ASC"
  def self.form_options
    self.all.map{|c| [c.name, c.id]}
  end
  
  def add_to_list(project)
    ProjectListItem.create(:project_id => project.id, :category_id => self.id)
  end
  
  def remove_from_list(project)
    conditions = {:project_id => project.id, :category_id => self.id}
    ProjectListItem.destroy_all(conditions)
  end
end
