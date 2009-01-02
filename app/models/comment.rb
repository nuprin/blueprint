class Comment < ActiveRecord::Base
  belongs_to :author, :class_name => "User"
  belongs_to :commentable, :polymorphic => true

  indexes_columns :text, :image_file_name, :using => :ferret

  has_attached_file :image,
    :styles => { :large => "360x360>" },
    :url  => "/assets/comments/:id/:style/:basename.:extension",
    :path =>
      ":rails_root/public/assets/comments/:id/:style/:basename.:extension"

  def to_s
    text
  end

  def self.form_for_object(commentable, author)
    commentable_type = commentable.is_a?(Task) ? "Task" : commentable.class.name
    attributes = {
      :author_id => author.id,
      :commentable_id => commentable.id,
      :commentable_type => commentable_type
    }
    self.new(attributes)
  end

  after_create do |comment|
    if comment.commentable_type == "Task"
      comment.author.subscribe_to(comment.commentable)
      comment.commentable.mass_mailer.ignoring(comment.author).
        deliver_task_comment(comment)
    end
  end  
end
