# Settings specified here will take precedence over those in config/environment.rb

HOST = 'localhost'

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
ActionMailer::Base.raise_delivery_errors = true
config.action_mailer.default_url_options = {:host => HOST}
ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.perform_deliveries = true

# Email account credentials
EMAIL_LOGIN = 'blueprint.tester@gmail.com'
EMAIL_PASSWORD = 'causes.com'
EMAIL_REPLY_TO = EMAIL_LOGIN

# Max size of a 'description' column
MAX_BODY_SIZE = 5000

