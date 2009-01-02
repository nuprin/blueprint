class ProjectMailer < ActionMailer::Base

  include MailerHelper
  include ProjectMailerHelper

  # TODO [chris]: I think there's a configuration option for this.
  default_url_options[:host] = HOST

  def new_comment(recipient, project, comment)
    project = comment.commentable

    recipients recipient_email(recipient)
    from       from_email(comment.author)
    subject    project_subject(project, "Spec")
    body       :comment => comment, :project => project
  end

  private
  
  def project_subject(project, subject)
    "[#{project.title}] #{subject}"
  end

end
