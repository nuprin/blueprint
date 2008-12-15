class Comment < ActiveRecord::Base
  belongs_to :task
  belongs_to :author, :class_name => "User"
end
