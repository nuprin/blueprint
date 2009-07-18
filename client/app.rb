#!/usr/bin/ruby

require 'api'
require 'readline'
require 'digest/md5'

COMMANDS = {
  "list" => :list,
  "userlist" => :user_list,
  "task" => :task,
  "projectlist" => :project_list,
  "addcomment" => :add_comment,
  "markcomplete" => :mark_complete
}

def output_tasks(tasks)
  tasks.each do |task|
    puts "#{task['id']}:#{task['title']}"
  end
end

def output_projects(projects)
  projects.each do |project|
    puts "#{project['id']}:#{project['title']}"
  end
end

USER = "frew"
def add_comment(c, args)
  comment = edit("")
  user = args.split(" ").first
  task_id = args.split(" ").last
  c.add_comment(:id => task_id, :user => user, :text => comment) 
end

def mark_complete(c, args)
  comment = edit("")
  user = args.split(" ").first
  task_id = args.split(" ").last
  c.mark_complete(:id => task_id, :user => user, :text => comment) 
end

def list(c, args)
  tasks = c.list_tasks
  output_tasks(tasks)
end

def user_list(c, args)
  tasks = c.list_tasks(:user => args)
  output_tasks(tasks)
end

def project_list(c, args)
  call_args = {}
  if args.length > 0
    call_args["status"] = args
  end
  projects = c.list_projects(call_args)
  output_projects(projects)
end

def edit(text)
  digest = Digest::MD5.hexdigest("#{rand(2**30)}")
  filename = "/tmp/#{digest}"
  tmp_file = File.new(filename, "w")
  tmp_file.write(text)
  tmp_file.close
  system(ENV["EDITOR"], filename)
  tmp_file = File.new(filename, "r")
  edited_text = tmp_file.read
end

c = BlueprintClient.new

while line = Readline.readline('bp> ', true)
  components = line.split(' ', 2)
  command = components.first
  args = components.size > 1 ? components.last : ""
  method(COMMANDS[command]).call(c, args)
end
