module MailerHelper
  FROM_EMAIL           = "blueprint@causes.com"
  FROM_EMAIL_WITH_NAME = "Blueprint <#{FROM_EMAIL}>"

  def self.included(base)
    base.module_eval do
    end
  end

  def recipient_email(recipient)
    "#{recipient.name} <#{recipient.email}>"
  end

  def from_email(user)
    "#{user.name} <#{FROM_EMAIL}>"
  end
end