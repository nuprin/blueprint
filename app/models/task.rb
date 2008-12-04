class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :creator, :class_name => 'User'
  belongs_to :asignee, :class_name => 'User'

  validates_presence_of :creator

  validates_numericality_of :estimate, :less_than_or_equal_to => 20,
                                       :allow_nil => true

  validates_length_of :title, :in => 1...255
  validates_length_of :description, :maximum => 5000, :allow_nil => true
end
