class ProjectCategory < ActiveRecord::Base
  has_many :projects
  named_scope :sorted, :order => "name ASC"
  def self.form_options
    self.all.map{|c| [c.name, c.id]}
  end
end
