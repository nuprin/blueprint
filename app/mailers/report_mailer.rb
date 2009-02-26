class ReportMailer < ActionMailer::Base
  REPLY_TO = "Blueprint <blueprint@causes.com>"
  def scrum_report
    from       REPLY_TO
    reply_to   REPLY_TO
    subject    "Scrum Notes: #{Time.now.strftime("%b %e, %Y")}"
    recipients "chris@causes.com"
    content_type "text/html"
  end
end
