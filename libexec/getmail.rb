require 'net/imap'

LOGIN = 'philbot@project-agape.com'
EMAIL = 'arefin'

def remove_quotation(text)
  lines = text.split(/\n/)

  date = lines.index do |line|
    /^On.*wrote:$/.match(line)
  end

  if date
    comment, quotation = lines[0...date], lines[date+1..-1]
  else
    comment, quotation = lines, []
  end
  quotation.reject! do |line|
    line =~ /^\s*>/
  end

  nonempty_lines = quotation.select do |line|
    !line.gsub(/\s/, '').blank?
  end

  result = comment
  if nonempty_lines.any?
    result.push(lines[date])
    result += nonempty_lines
  end

  result.join("\n")
rescue => bang
  puts "Error: #{bang}"
  puts bang.backtrace
  text
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
    
    from_struct = envelope.from[0]
    from_address = from_struct.mailbox + "@" + from_struct.host

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
    
    date_string = envelope.date
    
    subj_string = envelope.subject
    task_id_string = subj_string.match('#\d+')[0]

    puts task_id_string

    task_id = Integer(task_id_string.split("#")[1])
    
    raw_body = raw_msg.attr["BODY[1]"]
    comment = remove_quotation(raw_body)

    #create a comment from the info above
    t = Task.find(task_id)
    comment_params = {
      :author_id => user.id, :commentable => t, :text => raw_body
    }
    c = Comment.create!(comment_params)
    
    # Delete the message when we're done with it
    connection.store(message_id, "FLAGS", [:Deleted])
end

connection.logout
# rkabir's local environment requires a separate disconnect call.
# connection.disconnect
