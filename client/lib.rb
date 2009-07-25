require 'pp'

# Largely from http://snippets.dzone.com/posts/show/563
def parse_ini_file(path)
  full_path = File.expand_path(path)
  input_file = File.new(full_path)
  input = input_file.read()
  input_file.close()
  tamed = {}

  input = input.split(/\[([^\]]+)\]/)[1..-1]
  # sort the data into key/value pairs
  input.inject([]) do |tary, field|
    tary << field
    if(tary.length == 2)
      # we have a key and value; put 'em to use
      tamed[tary[0]] = tary[1].sub(/^\s+/,'').sub(/\s+$/,'')
      # pass along a fresh temp-array
      tary.clear
    end
    tary
  end

  tamed.dup.each do |tkey, tval|
    tvlist = tval.split(/[\r\n]+/)
    tamed[tkey] = tvlist.inject({}) do |hash, val|
      yield hash if val.index('=') == nil || val.strip[0] == '#'
      k, v = val.split(/=/)
      hash[k.strip]=v.strip
      hash
    end
  end
  tamed
end

def parse_git_email
  gitconfig_hash = parse_ini_file("~/.gitconfig")
  user_section = gitconfig_hash["user"]
  return nil if user_section.nil?
  email = user_section["email"]
end

class InsufficientContextException < Exception
end

class Context
  attr_accessor :user_email, :project_id

  def user_email!
    raise InsufficientContextException("No assignee specified") if @user_email.nil?
    @user_email
  end

  def user_name
    user_email!.split('@')[0]
  end

  def project_id!
    raise InsufficientContextException("No project specified") if @project_id.nil?
    project_id
  end

  def initialize(user_email=parse_git_email, project_id=nil)
    @user_email = user_email
    @project_id = project_id
  end

  def to_s
    str = ""
    str += "#{user_name}" if user_email
    str += " p#{project_id}" if project_id
    return str
  end
end

# Open a file in EDITOR and read its contents when done editing
def edit(text)
  digest = Digest::MD5.hexdigest("#{rand(2**30)}")
  filename = "/tmp/bp-#{digest}"
  tmp_file = File.new(filename, "w")
  tmp_file.write(text)
  tmp_file.close
  system(ENV["EDITOR"], filename)
  tmp_file = File.new(filename, "r")
  edited_text = tmp_file.read
  # We're intentionally not deleting files for now
end

def remove_comments(text)
  text = text.select do |line|
    line !~ /^#/
  end
  text
end
