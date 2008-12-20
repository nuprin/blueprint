class Comment < ActiveRecord::Base
  belongs_to :task
  belongs_to :author, :class_name => "User"

  after_create do |comment|
    comment.deliver_comment_creation_emails
  end
  
  def deliver_comment_creation_emails
    # TODO [chris]: The assignee should be on the CC list.
    list = (self.task.subscribed_users + [self.task.assignee]).uniq
    list.delete(self.author)
    list.each do |rec|
      TaskMailer.deliver_task_comment(rec, self)
    end    
  end

has_attached_file :image,
  :styles => { :large => "360x360>" },
  :url  => "/assets/comments/:id/:style/:basename.:extension",
  :path => ":rails_root/public/assets/comments/:id/:style/:basename.:extension"
end
