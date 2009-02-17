class Feature < ActiveRecord::Base
  has_many :tasks
  def self.form_options
    self.all.map{|feature| [feature.name, feature.id]}.sort
  end
end
