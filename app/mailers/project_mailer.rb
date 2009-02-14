class ProjectMailer < ActionMailer::Base

  include MailerHelper
  include ProjectMailerHelper

  def new_comment(recipient, project, comment)
    project = comment.commentable

    recipients recipient_email(recipient)
    from       from_email(comment.author)
    subject    project_subject(project, "Spec")
    body       :comment => comment, :project => project
  end

  private
  
  def project_subject(project, subject)
    "(Blueprint) #{project.title} #{subject}"
  end

end
