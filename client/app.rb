#!/usr/bin/env ruby

require 'digest/md5'
require 'pp'
require 'readline'
require 'rubygems'
require 'activesupport'

require 'api'
require 'lib'
require 'command_completer'

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
PROJECT_ID = "PROJECT:"
ESTIMATE_ID = "ESTIMATE:"
STATUS_ID = "STATUS:"
DUEDATE_ID = "DUE DATE:"
TASK_TEMPLATE =
"""
#{TITLE_ID} TITLE
#{ASSIGNEE_ID} ASSIGNEE
##{DUEDATE_ID} DUEDATE
##{PROJECT_ID} PROJECT
##{ESTIMATE_ID} ESTIMATE
##{STATUS_ID} STATUS
## DESCRIPTION ##

""".strip()

DEFAULT_DOMAIN="causes.com"

# Global Variables
CL = BlueprintClient.new
CON = Context.new
CC = CommandCompleter.new

CC.add_command("add_comment", :add_comment)
CC.add_command("complete", :mark_complete)
CC.add_command("help", :help)
CC.add_command("list", :list)
CC.add_command("mark_complete", :mark_complete)
CC.add_command("edit_task", :edit_task)
CC.add_command("new_task", :new_task)
CC.add_command("project_list", :project_list)
CC.add_command("re_prioritize", :reprioritize)
CC.add_command("set_project", :set_project)
CC.add_command("set_user", :set_user)
CC.add_command("task", :task)

# String Formatting Helpers
def comment_string(comment)
  s = format("%s\n%s\n  %s\n", comment['updated_at'], comment['text'],
                       comment['author_name'])
end

def comments_string(comments)
  comments = comments.map { |comment| comment_string(comment) }
  comments.join
end

# Printing Helpers
def help(cl, con, args)
  commands = CC.commands.map(&:command)
  commands.sort.each do |command|
    puts command
  end
end

def output_comments(comments)
  puts comments_string(comments)
end

def output_task(task, extended=false)
  user = task['assignee_email'].split('@').first

  task_string = format("%s:%s", task['id'], task['title'])
  task_string = user.to_s + "\t#{task_string}"
  task_string += " $#{task['due_date']}" if task['due_date']
  task_string += " #{task['estimate']}h" if task['estimate']
  puts task_string
  puts task['description'] if extended
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

def edit_task(cl, con, args)
  author_email = con.user_email!
  task_id = args.first
  task = cl.task(:id => task_id)
  task_data = task_to_template(task)
  task_text = edit(task_data)
  task_params = parse_task(task_text)
  task_params['id'] = task_id
  cl.edit_task(task_params)
end

def new_task(cl, con, args)
  task = HashWithIndifferentAccess.new
  task['author_email'] = con.user_email!
  task['assignee_email'] = args.first || con.user_email
  task['project_id'] = con.project_id

  task_data = task_to_template(task)
  # User edits the template file
  task_text = edit(task_data)
  task_params = parse_task(remove_comments(task_text))
  task_params['author_email'] = task['author_email']
  if task_params['title'] == "" || task_params['assignee_email'] == ""
    puts "You must supply a Title & Assignee at the minimum"
    return
  else
    cl.new_task(task_params)
  end
end

def reprioritize(cl, con, args)
  rp_task = args[0]
  rel_pos = args[1]
  base_task = args[2]
end

# Retrieving Functions
def list(cl, con, args)
  argh = {}
  argh['status'] = "prioritized"
  argh['assignee_email'] = "#{args[1]}@#{DEFAULT_DOMAIN}" if args.length == 2
  argh['status'] = args[0] if args.length >= 1

  if argh['assignee_email'] == nil && con.project_id == nil
    argh['assignee_email'] = con.user_email!
  end

  argh['project_id'] = con.project_id
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
  output_task(task, true)
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
        task['kind'] = line.gsub(/^#{KIND_ID}/, "").strip()
      when /^#{TITLE_ID}/
        task['title'] = line.gsub(/^#{TITLE_ID}/, "").strip()
      when /^#{PROJECT_ID}/
        task['project_id'] = line.gsub(/^#{PROJECT_ID}/, "").strip()
      when /^#{DUEDATE_ID}/
        task['due_date'] = line.gsub(/^#{DUEDATE_ID}/, "").strip()
      when /^#{ESTIMATE_ID}/
        task['estimate'] = line.gsub(/^#{ESTIMATE_ID}/, "").strip().to_i
      when /^#{ASSIGNEE_ID}/
        task['assignee_email'] = line.gsub(/^#{ASSIGNEE_ID}/, "").strip()
      else
        description += "#{line}\n"
    end
  end
  task['description'] = description
  task
end

def task_to_template(task)
  # Insert data into the template
  task_data = TASK_TEMPLATE.dup
  task_data.gsub!(/ASSIGNEE$/, task['assignee_email'].to_s)
  task_data.gsub!(/DUEDATE$/, task['due_date'].to_s)
  task_data.gsub!(/ESTIMATE$/, task['estimate'].to_s)
  task_data.gsub!(/PROJECT$/, task['project_id'].to_s.to_s)
  task_data.gsub!(/STATUS$/, task['status'].to_s)
  task_data.gsub!(/TITLE$/, task['title'].to_s)
  task_data += "\n#{task['description']}" if task['description']
  task_data
end

while line = Readline.readline("bp #{CON}> ", true)
  components = line.split(' ', 2)
  command = components.first
  args = components.size > 1 ? components.last : ""
  args = args.split
  begin
    possible_commands = CC.find_command(command)
    if possible_commands.empty?
      puts "Unrecognized command: #{command}"
      next
    elsif possible_commands.size > 1
      puts "Ambiguous directive: (could be one of the following)"
      possible_commands.each do |pcommand|
        puts pcommand.command
      end
      next
    else
      exec_command = possible_commands.first
      puts "executing #{exec_command.command}"
    end
    method(exec_command.callback).call(CL, CON, args)
  rescue InsufficientContextException => ice
    puts "Insufficient context for this command: try again with more args"
  end
end
