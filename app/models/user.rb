class User < ActiveRecord::Base
  validates_length_of :name, :in => 1...50
  validates_numericality_of :fbuid, :allow_nil => true
end
