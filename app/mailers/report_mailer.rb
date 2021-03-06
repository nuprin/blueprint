class ReportMailer < ActionMailer::Base
  REPLY_TO = EMAIL_REPLY_TO
  def scrum_report
    from       REPLY_TO
    reply_to   REPLY_TO
    subject    "Scrum Notes: #{Time.now.strftime("%b %e, %Y")}"
    recipients "eng@causes.com"
    content_type "text/html"
  end
end
