class Project < ActiveRecord::Base
  has_many :task_list_items, :as => :context
  has_many :tasks

  validates_length_of :title, :in => 1...255
  validates_length_of :description, :maximum => 5000, :allow_nil => true
end
