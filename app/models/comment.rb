class Comment < ActiveRecord::Base
  belongs_to :task
  belongs_to :author, :class_name => "User"

  after_create do |comment|
    list = comment.task.task_subscriptions.map(&:user) + [comment.task.assignee]
    list = list.compact.uniq
    list.delete(comment.author)
    list.each do |rec|
      TaskMailer.deliver_task_comment(rec, comment)
    end
  end
has_attached_file :image,
  :styles => { :large => "360x360>" },
  :url  => "/assets/comments/:id/:style/:basename.:extension",
  :path => ":rails_root/public/assets/comments/:id/:style/:basename.:extension"
end
