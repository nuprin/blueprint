#!/usr/bin/ruby

require 'api'
require 'readline'
require 'digest/md5'

AUTHOR_EMAIL = "okay@causes.com"
COMMANDS = {
  "list" => :list,
  "userlist" => :userlist,
  "task" => :task,
  "projectlist" => :project_list,
  "addcomment" => :add_comment,
  "markcomplete" => :mark_complete
}

# Printing Helpers
def output_task(task)
  y task
end

def output_tasks(tasks)
  tasks.each do |task|
    puts "#{task['id']}:#{task['title']}"
  end
end

def output_comments(comments)
  comments.each do |comment|
    y comment
  end
end

def output_projects(projects)
  projects.each do |project|
    puts "#{project['id']}:#{project['title']}"
  end
end

# Editing Functions
def add_comment(c, args)
  comment = edit("")
  task_id = args.split(" ").last
  c.add_comment(:id => task_id, :author_email => AUTHOR_EMAIL, :text => comment) 
end

def mark_complete(c, args)
  comment = edit("")
  task_id = args.split(" ").last
  c.mark_complete(:id => task_id, :author_email => AUTHOR_EMAIL, :text => comment) 
end

# Retrieving Functions
def list(c, args)
  tasks = c.list_tasks
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

def task(c, args)
  task_id = args.split(" ").first
  task = c.task(:id => task_id)
  output_task(task)
  comments = c.list_comments(:id => task_id)
  output_comments(comments)
end

def userlist(c, args)
  tasks = c.list_tasks(:author_email => args)
  output_tasks(tasks)
end

# Open a file in EDITOR and read its contents when done editing
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
