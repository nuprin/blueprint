class Comment < ActiveRecord::Base
  belongs_to :task
  belongs_to :author, :class_name => "User"

  has_attached_file :image,
    :styles => { :large => "360x360>" },
    :url  => "/assets/comments/:id/:style/:basename.:extension",
    :path =>
      ":rails_root/public/assets/comments/:id/:style/:basename.:extension"

  after_create do |comment|
    comment.author.subscribe_to(comment.task)
    comment.task.mass_mailer.ignoring(comment.author).
      deliver_task_comment(comment)
  end  
end
