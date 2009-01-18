class ProjectCategory < ActiveRecord::Base
  has_many :projects
  def self.form_options
    self.all.map{|c| [c.name, c.id]}
  end
end
