class Comment < ActiveRecord::Base
  belongs_to :author, :class_name => "User"
  belongs_to :commentable, :polymorphic => true

  validate :must_have_text_or_photo
  
  has_attached_file :image,
    :styles => { :large => "360x360>" },
    :url  => "/assets/comments/:id/:style/:basename.:extension",
    :path =>
      ":rails_root/public/assets/comments/:id/:style/:basename.:extension"

  def must_have_text_or_photo
    if self.image_file_name.blank? && self.text.blank?
      errors.add_to_base("must have text or a photo")
    end
  end

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
    comment.author.subscribe_to(comment.commentable)
    comment.subscribe_anyone_mentioned
  end
  
  after_save do |comment|
    comment.send_later(:send_comment_email)
  end

  def subscribe_anyone_mentioned
    self.mentioned_users.each do |user|
      user.subscribe_to(self.commentable)
      # TODO [chris]: Ensure that a TaskEdit is created and that the new
      # user is notified.
    end
  end

  def mentioned_users
    User.active.select do |user|
      self.text.include?(user.name)
    end
  end

  def send_comment_email
    commentable.mass_mailer.ignoring(author).deliver_new_comment(self)
  end

end
