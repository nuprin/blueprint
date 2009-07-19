#!/usr/bin/ruby

require 'api'
require 'readline'
require 'digest/md5'

# A task has
# title, description, kind, status, project_id, creator_id, assignee_id
# estimate, due_data
KINDS = [
  "bug", "copy", "design", "estimate", "experiment", "feature", "inquiry",
  "spec", "stats"
]
KIND_ID = "KIND:"
TITLE_ID = "TITLE:"
ASSIGNEE_ID = "USER:"
ESTIMATE_ID = "ESTIMATE:"
PROJECT_ID = "PROJECT:"
TASK_TEMPLATE =
"""
#{TITLE_ID} TITLE
#{ASSIGNEE_ID} ASSIGNEE
#{ESTIMATE_ID} ESTIMATE
#{PROJECT_ID} PROJECT
## DESCRIPTION ##

""".strip()

AUTHOR_EMAIL = "okay@causes.com"
COMMANDS = {
  "list" => :list,
  "userlist" => :userlist,
  "task" => :task,
  "projectlist" => :project_list,
  "addcomment" => :add_comment,
  "markcomplete" => :mark_complete,
  "new" => :new_task
}


def comment_string(comment)
  s = format("%s\n%s\n  %s\n", comment['updated_at'], comment['text'],
                       comment['author_name'])
end

def comments_string(comments)
  comments = comments.map { |comment| comment_string(comment) }
  comments.join
end
# Printing Helpers
def output_comments(comments)
  puts comments_string(comments)
end

def output_task(task)
  puts format("%s:%s", task['id'], task['title'])
end

def output_tasks(tasks)
  tasks.each do |task|
    output_task(task)
  end
end

def output_projects(projects)
  projects.each do |project|
    puts format("%s:%s", project['id'], project['title'])
  end
end

# Editing Functions

# if no user is supplied, create it for the default user, otherwise give it to
# another user.
def add_task(c, args)
  # a task should open in a new editor window. Format of a new task
  task_string = edit("")
end

def add_comment(c, args)
  task_id = args.split(" ").last
  begin
    comments = comments_string(c.list_comments(:id => task_id))
  rescue NoMethodError => e
    puts e
  end
  comments = comments.map { |line| line.gsub(/^/, "#" ) }
  comment = edit(comments)
  comment = parse_comments(comment)
  if comment.empty?
    puts "Can't post empty comment"
    return
  end
  puts "Posting #{comment} to task :#{task_id}"
  c.add_comment(:id => task_id, :author_email => AUTHOR_EMAIL, :text => comment)
end

def mark_complete(c, args)
  comment = edit("")
  task_id = args.split(" ").last
  puts "Marking task :#{task_id} complete"
  c.mark_complete(:id => task_id, :author_email => AUTHOR_EMAIL, :text => comment)
end

def new_task(c, args)
  author_id = AUTHOR_EMAIL
  assignee_id = args.split(" ").first
  assignee_id = AUTHOR_EMAIL if assignee_id.nil?
  task_text = edit(TASK_TEMPLATE.gsub(/ASSIGNEE/, assignee_id))
  task_params = parse_task(parse_comments(task_text))
  task_params[:author_email] = author_id
  c.new_task(task_params)
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
  tasks = c.list_tasks(:assignee_email => args)
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

def parse_comments(text)
  text = text.select do |line|
    line =~ /^[^#]+/
  end
  text
end
# Parse the edited task
# Title: (mandatory)
# Due: (can be commented out)
# Priority: (can be commented out)
# Feature: (can be commented out)
# The rest of the lines are all the description

def parse_task(text)
  task = {}
  description = ""
  text.each do |line|
    next if line =~ /^#/
    line = line.strip()
    case line
      when /^#{KIND_ID}/
        task[:kind] = line.gsub(/^#{KIND_ID}/, "").strip()
      when /^#{TITLE_ID}/
        task[:title] = line.gsub(/^#{TITLE_ID}/, "").strip()
      when /^#{ESTIMATE_ID}/
        task[:estimate] = line.gsub(/^#{ESTIMATE_ID}/, "").strip()
      when /^#{PROJECT_ID}/
        task[:project_id] = line.gsub(/^#{PROJECT_ID}/, "").strip()
      when /^#{ASSIGNEE_ID}/
        task[:assignee_email] = line.gsub(/^#{ASSIGNEE_ID}/, "").strip()
      else
        description += line
    end
  end
  task[:description] = description
  task
end

c = BlueprintClient.new

while line = Readline.readline('bp> ', true)
  components = line.split(' ', 2)
  command = components.first
  args = components.size > 1 ? components.last : ""
  method(COMMANDS[command]).call(c, args)
end
