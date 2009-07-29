#!/usr/bin/env ruby

require 'digest/md5'
require 'pp'
require 'readline'
require 'abbrev'

require 'rubygems'
require 'activesupport'

require 'api'
require 'lib'
require 'template'
require 'command_completer'

DEFAULT_DOMAIN="causes.com"

# Global Variables
CL = BlueprintClient.new
CON = Context.new
CC = CommandCompleter.new
# String Formatting Helpers
def line_delimiter
  "#{"-" * 50}\n"
end


def comment_string(comment)
  s = format("[%s] %s\n%s\n\n", comment['author_name'], comment['updated_at'],
                                comment['text'])
end

def comments_string(comments)
  comments = comments.map do |comment|
    comment_string(comment) + line_delimiter
  end
  comments.join
end

def ellipsize(str, len=80)
  len -= "..".size
  size_diff = len - str.size
  padding = size_diff > 0 ?  " " * (size_diff + "..".size + 1) : ".."

  "#{str[0..len]}#{padding}"
end

# Printing Helpers
def help(cl, con, args)
  commands = CC.commands
  puts 'Available commands'
  commands.sort.each do |command|
    puts command
  end
end

def output_comments(comments)
  puts comments_string(comments)
end

def output_task(task, extended=false)
  email = task['assignee_email']
  time_str = nil
  time_str = Time.parse(task['due_date']).strftime("%b %d") if task['due_date']

  if extended
    task_string = format(":%s\n%s", task['id'], task['title'])
    task_string += "\n#{line_delimiter}"
    task_string += "\nDue: #{time_str}"if time_str
    task_string += "\nEstimate: #{task['estimate']}h" if task['estimate']
  else
    task_string = format(":%s %s", task['id'], ellipsize(task['title'], 50))
    task_string += " #{time_str}" if time_str
    task_string += " #{task['estimate']}h" if task['estimate']
  end

  puts task_string
  puts task['description'] if extended
end

def output_tasks(tasks)
  tasks_for_user = Hash.new
  tasks.each do |task|
    assignee = task['assignee_email']
    assignee ||= "unassigned@causes.com"
    tasks_for_user[assignee] ||= []
    tasks_for_user[assignee] << task
  end

  puts ""
  users = tasks_for_user.keys.sort
  users.each do |user_email|
    assignee = user_email.split('@').first
    puts "(#{assignee})"
    tasks_for_user[user_email].each do |task|
      output_task(task)
    end
    puts ""
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
    puts "You can't post empty comment"
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

  task_data = TaskTemplate.new
  task_data.update(task)

  task_text = edit(task_data.to_template)

  task_data = TaskTemplate.from_template(task_text)
  task_data[:id] = task_id

  cl.edit_task(task_data.to_symbol_hash)
end

def new_task(cl, con, args)
  task = {}
  task['assignee_email'] = args.first || con.user_email
  task['project_id'] = con.project_id

  task_data = TaskTemplate.new
  task_data.update(task)
  # User edits the template file
  task_text = edit(task_data.to_template)
  task_data = TaskTemplate.from_template(task_text)
  task_data[:author_email] = con.user_email!

  if task_data['title'] == ""
    puts "You must supply a Title"
  else
    task = cl.new_task(task_data.to_symbol_hash)
    output_task(task)
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

def setup
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
  CC.add_command("show", :task)
  CC.add_command("task", :task)

  # readline setup
  Readline.completion_proc = Proc.new do  |tok|
   commands = CC.find_command(tok).map(&:command)
   commands.map { |c| c.gsub(/_/, '') }
  end
  Readline.completion_append_character
end

def handle_line(line)
  components = line.split(' ', 2)
  command = components.first
  # Do nothing if the command is empty
  next if command.nil? || command.strip().empty?

  args = components.size > 1 ? components.last : ""
  args = args.split

  begin
    possible_commands = CC.find_command(command)

    if possible_commands.empty?
      puts "Unrecognized command: #{command}"
    elsif possible_commands.size > 1
      puts "Ambiguous directive: (could be one of the following)"
      possible_commands.each { |pcommand| puts pcommand.command }
    else
      exec_command = possible_commands.first
      puts "executing #{exec_command.command}\n"
      method(exec_command.callback).call(CL, CON, args)
    end
  rescue InsufficientContextException => ice
    puts "Insufficient context for this command: try again with more args"
  end

end

def main
    while line = Readline.readline("bp #{CON}> ", true)
      handle_line(line)
    end
end

setup
main
