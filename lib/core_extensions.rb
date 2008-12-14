class String
  def possessive
    self.last == 's' ? "#{self}'" : "#{self}'s"
  end
end