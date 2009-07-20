#!/usr/bin/ruby

require 'api'
require 'lib'
require 'readline'
require 'digest/md5'
require 'pp'

# A task has
# title, description, kind, status, project_id, creator_id, assignee_id
# estimate, due_data
KINDS = [
  "bug", "copy", "design", "estimate", "experiment", "feature", "inquiry",
  "spec", "stats"
]
KIND_ID = "KIND:"
TITLE_ID = "TITLE:"
ASSIGNEE_ID = "ASSIGNEE:"
ESTIMATE_ID = "ESTIMATE:"
PROJECT_ID = "PROJECT:"
TASK_TEMPLATE =
"""
#{TITLE_ID}
#{ASSIGNEE_ID} ASSIGNEE
#{ESTIMATE_ID}
#{PROJECT_ID}
## DESCRIPTION ##

""".strip()

DEFAULT_DOMAIN="causes.com"

COMMANDS = {
  "l" => :list,
  "list" => :list,
  "ts" => :list,

  "task" => :task,
  "t" => :task,

  "rp" => :reprioritize,

  "projectlist" => :project_list,
  "pl" => :project_list,
  "ps" => :project_list,

  "addcomment" => :add_comment,

  "markcomplete" => :mark_complete,
  "c" => :mark_complete,

  "new" => :new_task,
  "n" => :new_task,

  "newcomplete" => :new_complete_task,
  "nc" => :new_complete_task,

  "setproject" => :set_project,
  "sp" => :set_project,

  "setuser" => :set_user,
  "su" => :set_user,

  "help" => :help
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

# Context Functions
def set_project(cl, con, args)
  project_id = nil
  project_id = args[0] if args.size > 0
  con.project_id = project_id
end

def set_user(cl, con, args)
  con.user_email = "#{args[0]}@#{DEFAULT_DOMAIN}"
end

# Editing Functions

# if no user is supplied, create it for the default user, otherwise give it to
# another user.
def add_task(cl, con, args)
  # a task should open in a new editor window. Format of a new task
  task_string = edit("")
end

def add_comment(cl, con, args)
  author_email = con.user_email!
  task_id = args.last
  comments = comments_string(cl.list_comments(:id => task_id))
  comments = comments.map { |line| line.gsub(/^/, "#" ) }
  comment = edit(comments)
  comment = remove_comments(comment)
  if comment.empty?
    puts "Can't post empty comment"
    return
  end
  puts "Posting #{comment} to task :#{task_id}"
  cl.add_comment(
    :id => task_id,
    :author_email => author_email,
    :text => comment)
end

def mark_complete(cl, con, args)
  author_email = con.user_email!
  task_id = args.last
  comment = edit("")
  puts "Marking task :#{task_id} complete"
  cl.mark_complete(
    :id => task_id,
    :author_email => author_email,
    :text => comment)
end

def new_task(cl, con, args)
  author_email = con.user_email!
  assignee_email = args.first
  assignee_email = con.user_email if assignee_email.nil?
  task_text = edit(TASK_TEMPLATE.gsub(/ASSIGNEE$/, assignee_email))
  task_params = parse_task(remove_comments(task_text))
  task_params[:author_email] = author_email 
  cl.new_task(task_params)
end

def reprioritize(cl, con, args)
  rp_task = args[0]
  rel_pos = args[1]
  base_task = args[2]
end

# Retrieving Functions
def list(cl, con, args)
  argh = {}
  argh[:status] = "prioritized"
  argh[:assignee_email] = "#{args[1]}@#{DEFAULT_DOMAIN}" if args.length == 2
  argh[:status] = args[0] if args.length >= 1

  if argh[:assignee_email] == nil && con.project_id == nil
    argh[:assignee_email] = con.user_email!
  end

  argh[:project_id] = con.project_id
  tasks = cl.list_tasks(argh)
  output_tasks(tasks)
end

def project_list(cl, con, args)
  call_args = {}
  if args.length > 0
    call_args["status"] = args
  end
  projects = cl.list_projects(call_args)
  output_projects(projects)
end

def task(cl, con, args)
  task_id = args.first
  task = cl.task(:id => task_id)
  output_task(task)
  comments = cl.list_comments(:id => task_id)
  output_comments(comments)
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

cl = BlueprintClient.new
con = Context.new

while line = Readline.readline("bp #{con}> ", true)
  components = line.split(' ', 2)
  command = components.first
  args = components.size > 1 ? components.last : ""
  args = args.split
  begin
    method(COMMANDS[command]).call(cl, con, args)
  rescue InsufficientContextException => ice
    puts "Insufficient context for this command: try again with more args"
  end
end
