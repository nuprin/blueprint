# A sample client for retrieving information from Delicious.
# Delicious JSON feed documentation: http://delicious.com/help/feeds

require File.join(File.dirname(__FILE__), "..", "lib", "bricklayer")
require 'json'

class TastyFeed < Bricklayer::Base
  JSON_PARSER = Proc.new {|json_response| JSON.parse(json_response) }
  service_url "http://feeds.delicious.com/v2/json/{which}", :default_parameters => {:which => ""}, &JSON_PARSER
  remote_method :hotlist
  remote_method :recent, :override_paramters => {:which => "recent"}
  remote_method :popular, :override_parameters => {:which => "popular"}
  remote_method :alerts, :override_parameters => {:which => "alerts"}

  service_url "http://feeds.delicious.com/v2/json/tag/{tags}", &JSON_PARSER
  remote_method :tagged, :required_parameters => [:tags]

  service_url "http://feeds.delicious.com/v2/json/popular/{tag}", &JSON_PARSER
  remote_method :popular_with_tag, :required_parameters => [:tag]


  # For whatever reason, combining this service url and the next causes a 404 when calling user_bookmarks,
  # (because of the trailing slash?) so I'm specifying it separately.
  service_url "http://feeds.delicious.com/v2/json/{username}", &JSON_PARSER
  remote_method :user_bookmarks, :required_parameters => [:username]
  
  service_url "http://feeds.delicious.com/v2/json/{username}/{tags}", :default_parameters => {:tags => ""}, &JSON_PARSER
  remote_method :user_bookmarks_tagged, :required_parameters => [:username, :tags]
  
  service_url "http://feeds.delicious.com/v2/json/{service}/{username}", :default_parameters => {:tags => ""}, &JSON_PARSER
  remote_method :user_info, :required_parameters => [:username], :override_parameters => {:service => "userinfo"}
  remote_method :user_tags, :required_parameters => [:username], :override_parameters => {:service => "tags"}
  remote_method :user_subscription_bookmarks, :required_parameters => [:username], :override_parameters => {:service => "subscriptions"}
  remote_method :user_inbox, :required_parameters => [:username, :private], :override_parameters => {:service => "inbox"}
  remote_method :user_network_bookmarks, :required_parameters => [:username], :override_parameters => {:service => "network"}
  remote_method :user_network_members, :required_parameters => [:username], :override_parameters => {:service => "networkmembers"}
  remote_method :user_network_fans, :required_parameters => [:username], :override_parameters => {:service => "networkfans"}
  
  service_url "http://feeds.delicious.com/v2/json/{service}/{username}/{tags}", :default_parameters => {:tags => ""}, &JSON_PARSER
  remote_method :user_network_bookmarks_tagged, :required_parameters => [:username, :tags], :override_parameters => {:service => "network"}  
end
