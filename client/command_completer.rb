class CommandCompleter
  attr_reader :commands
  def initialize
    @commands = []
  end

  def add_command(command_name, method_name, num_args=0)
    command = Command.new(command_name, method_name, num_args)
    @commands << command
  end

  def find_command(command_substr)
    @commands.select { |command| command.regex.match(command_substr) }
  end
end

class Command
  attr_reader :command, :callback, :num_args
  def initialize(command_name, method_name, num_args=0)
    @command = command_name
    @callback = method_name
    @num_args = num_args
  end

  # add_comment => (a(d(d)?)?)?(c(o(m(m(e(n(t)?)?)?)?)?)?)?
  def regex
    @regex ||= create_regex
  end

  private
  def create_regex
    words = @command.split('_')
    command_regex = regex_from_word(words.first)
    words.delete_at(0) # just because I like deleting the first element
    words.each do |word|
      word_regex = regex_from_word(word)
      command_regex += "(#{word_regex})?"
    end
    command_regex = "^#{command_regex}$"
    Regexp.new(command_regex)
  end

  def regex_from_word(word)
    word.reverse!
    word_regex = word[0].chr
    [*1...word.size].each do |i|
        word_regex = "#{word[i].chr}(#{word_regex})?"
    end
    word_regex
  end
end

