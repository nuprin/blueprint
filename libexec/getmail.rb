require 'net/imap'

connection = Net::IMAP.new('imap.gmail.com',993,true)
connection.login('philbot@project-agape.com','arefin')
connection.select('INBOX')
messages = connection.search(['ALL'])

fetch_params = ['ENVELOPE', 'BODY[1]']

messages.each{ |message_id|
    #this will come in an array, of length 1
    #and raw_msg is FetchData
    raw_msg = connection.fetch(message_id,fetch_params)[0]
    envelope = raw_msg.attr["ENVELOPE"]
    
    from_struct = envelope.from[0]
    from_address = from_struct.mailbox + "@" + from_struct.host

    #TODO: here we could crunch through to get out the ID from the reply-to address
=begin
    recipients = envelope.to
    recipients.each { |r|
        if r.mailbox.index("+").nil?
            reply_to_task = Integer(r.mailbox.split["+"][1])
    }
=end    

    puts from_address
    #need to catch if the email isn't found!
    user = User.find_by_email(from_address)
    
    date_string = envelope.date
    
    subj_string = envelope.subject
    task_id_string = subj_string.match('#\d+')[0]

    puts task_id_string

    task_id = Integer(task_id_string.split("#")[1])
    
    #the following is a hack that basically pulls in a single part from a MIME/multipart message
    #seems to work with gmail for now.
    raw_body = raw_msg.attr["BODY[1]"]

    #create a comment from the info above
    c = Comment.new()
    c.author_id = user.id
    c.commentable = Task.find(task_id)

    #placeholder
    #c.created_at = Time.now
    c.text = raw_body

    c.save
    
    #delete the message when we're done with it
    #connection.store(message_id, "FLAGS", [:Deleted])
    }

connection.logout
connection.disconnect