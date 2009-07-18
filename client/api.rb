require 'bricklayer/lib/bricklayer'
require 'rubygems'
require 'json'

class BlueprintClient < Bricklayer::Base
  ARRAY_JSON_PARSER = Proc.new{|json_response| JSON.parse(json_response).map{|item| item.first.last} }
  ITEM_JSON_PARSER = Proc.new{|json_response| JSON.parse(json_response).first.last}

  API_PATH="http://marl:3000/api"
  service_url "#{API_PATH}/{action}.json", &ARRAY_JSON_PARSER
  remote_method :list_tasks, :override_parameters => {:action => "tasks"}
  remote_method :list_projects, :override_parameters => {:action => "projects"}

  service_url "#{API_PATH}/tasks/{id}/{action}.json", &ARRAY_JSON_PARSER
  remote_method :list_comments, :override_parameters => {:action => "comments"}

  service_url "#{API_PATH}/{action}/{id}.json", &ITEM_JSON_PARSER
  remote_method :task, :override_parameters => {:action => "tasks"},
                :required_parameters => [:id]

  service_url "#{API_PATH}/tasks/{action}/{id}"
  remote_method :add_comment, 
                :override_parameters => {:action => "comment"},
                :required_parameters => [:id, :text, :author_email],
                :request_method => :post

  remote_method :mark_complete, 
                :override_parameters => {:action => "mark_complete"},
                :required_parameters => [:id, :text, :author_email],
                :request_method => :post
end
