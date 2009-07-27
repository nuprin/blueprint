require 'net/imap'

LOGIN = EMAIL_LOGIN
EMAIL = EMAIL_PASSWORD

DATE_EX = /(.*)^On.*wrote:/m
def remove_quotation(text)
  (DATE_EX.match(text) ? $1 : text).strip
end

def delete_email(connection, message_id)
  connection.store(message_id, "FLAGS", [:Deleted])
end

def process_comment_text(raw_msg)
  raw_body = raw_msg.attr["BODY[1]"].gsub("=\r\n", '')
  remove_quotation(raw_body)
end

def get_addresses_from_struct(struct_list)
  emails = []
  (struct_list || []).each { |struct|
    emails << struct.mailbox + "@" + struct.host
  }
  return emails
end

def get_asignee_name_from_body(body)
  return if body==nil
  $1.strip if body.downcase =~ /^ *to\:(.+)/
end

def add_to_task_cc_list(task, email_list)
  (email_list || []).each do |cc_email|
    user = User.find_by_email(cc_email)
    task.subscriptions.create(:user_id => user.id) if user
    puts "#{user.name} will receive notification about this task." if user
  end
end

connection = Net::IMAP.new('imap.gmail.com', 993, true)
connection.login(LOGIN, EMAIL)
connection.select('INBOX')
messages = connection.search(['ALL'])

# The following is a hack that basically pulls in a single part from a 
# MIME/multipart message seems to work with gmail for now.
fetch_params = ['ENVELOPE', 'BODY[1]']

messages.each do |message_id|
  # This will come in an array, of length 1 and raw_msg is FetchData.
  raw_msg = connection.fetch(message_id,fetch_params)[0]
  envelope = raw_msg.attr["ENVELOPE"]
  body = raw_msg.attr["BODY[1]"]
  
  from_address = get_addresses_from_struct(envelope.from)[0]

  # TODO: here we could crunch through to get out the ID from the reply-to 
  # address.
=begin
  recipients = envelope.to
  recipients.each { |r|
      if r.mailbox.index("+").nil?
          reply_to_task = Integer(r.mailbox.split["+"][1])
  }
=end    

  puts from_address
  # Need to catch if the email isn't found!
  user = User.find_by_email(from_address)

  # If we can't identify this email address, send an error message to the 
  # sender.
  user ||= User.anonymous
  puts user.inspect

  subject = envelope.subject

  puts "Subject: #{subject}"

  # TODO: Only look at messages with Task IDs
  # TODO: Do we want to just delete the rest?

  if subject =~ /\(Blueprint\)\s+(.+)\s+Spec/
    title = $1
    if p = Project.find_by_title(title)
      puts "Processing comment for project #{p.id}."
      # TODO: Implement process_comment_text
      text = process_comment_text(raw_msg)
      c = Comment.new(:author_id => user.id, :commentable => p, :text => text)
      c.save!
      delete_email(connection, message_id)
    end
  elsif subject =~ /#(\d+)/
    task_id = $1.to_i
    text = process_comment_text(raw_msg)
    if t = Task.find_by_id(task_id)
      puts "Processing comment for task #{t.id}."
      c = Comment.new(:author_id => user.id, :commentable => t, :text => text)
      c.save!
      delete_email(connection, message_id)
    end
  elsif subject =~ /\((.+)\)(.+)/
    directive = $1.downcase
    title = $2.strip
    assignee = User.find_by_name(get_asignee_name_from_body(body))
    assignee = user if assignee == User.anonymous
    description = body
    if directive == "create"
      puts "Creating new task: #{title}, created by #{user.name}, assigned to #{assignee.name}"
      task = Task.new(:title => title, :status => "prioritized", :creator_id => user.id, :assignee_id => assignee.id, :description => description)
      task.save!
      puts "Task created with id #{task.id}"
      task.mass_mailer.deliver_task_creation
      delete_email(connection, message_id)
    end
  end
end

connection.logout

# rkabir's local environment requires a separate disconnect call.
# connection.disconnect
