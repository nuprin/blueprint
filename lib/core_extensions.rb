class String
  def possessive
    self.last == 's' ? "#{self}'" : "#{self}'s"
  end
end

module ActiveSupport::Inflector
  # Dehumanize turns some human readable sentence into an underscored legal
  # instance variable.
  def dehumanize(word)
    word.tr(' ', '_').delete('^a-zA-Z0-9_').downcase
  end
end

module ActiveSupport
  module CoreExtensions
    module String
      module Inflections
        def dehumanize
          Inflector.dehumanize(self)
        end
      end
    end
  end
end
