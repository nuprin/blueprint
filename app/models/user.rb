class User < ActiveRecord::Base
  has_many :task_list_items, :as => :context
  has_many :tasks

  validates_length_of :name, :in => 1...50
  validates_numericality_of :fbuid, :allow_nil => true
end
