class String
  def possessive
    self.last == 's' ? "#{self}'" : "#{self}'s"
  end
  
  def ellipsize(length, token = "...")
    return token if length <= 0
    return self if size <= length

    str = self[0, length]

    rindex = str.rindex(/\s/)
    unless rindex.nil?
      str = str[0, rindex]
    end
    str + token
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

module ActionView::Helpers::TextHelper
  # AUTO_LINK_REgularexpression : This version is the same as the Rails
  # constant, but without the trailing text.
  AUTO_LINK_RE = %r{
    (                          # leading text
      <\w+.*?>|                # leading HTML tag, or
      [^=!:/]|                 # leading punctuation, or
      ^                        # beginning of line
    )
    (
      (?:https?://)|           # protocol spec, or
      (?:www\.)                # www.*
    )
    (
      [-\w]+                   # subdomain or domain
      (?:\.[-\w]+)*            # remaining subdomains or domain
      (?::\d+)?                # port
      (?:/(?:(?:[~\w\+@%-]|(?:[,.;:][^\s$]))+)?)* # path
      (?:\?[\w\+@%&=.;-]+)?     # query string
      (?:\#[\w\-]*)?           # trailing anchor
    )
  }x
end
