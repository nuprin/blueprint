class IncidentMailer < ActionMailer::Base
  REPLY_TO = EMAIL_REPLY_TO
  def new_incident(incident)
    from         REPLY_TO
    reply_to     REPLY_TO
    subject      "#{incident.tag} #{incident.title}"
    recipients   "cindl@causes.com"
    content_type "text/html"
    body         :incident => incident
  end
end
