require File.join(File.dirname(__FILE__), "..", "lib", "bricklayer")
require 'json'
require 'pp'

class TwitterHouse < Bricklayer::Base
  # Set HTTP Basic Authentication
  # Alternatively, you can set it on the per-instance level, e.g.,
  # @tc.authenticate("username","password") and it will override these settings
  authenticate "username", "password"
  
  # Set service URL. This will be used for all subsequent remote_method calls
  # until another is set
  # :default_parameters will be the defaults if neither remote_method or the method call itself don't set it.
  service_url "http://twitter.com/statuses/{action}.{format}", :default_parameters => {:format => "json"}

  # Define a remote method.  :override_parameters prevents the user from redefining
  # the {action} token when making the call.
  remote_method :friends_timeline, :override_parameters => {:action => "friends_timeline"} do |json_response|
    JSON.parse(json_response)
  end


end

tc = TwitterHouse.new
timeline = tc.friends_timeline # => returns the parsed JSON response from Twitter