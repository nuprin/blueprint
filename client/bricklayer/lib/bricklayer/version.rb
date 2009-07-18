module Bricklayer
  VERSION = '0.1.1' unless defined?(Bricklayer::VERSION)
 
  # Merb::RELEASE meanings:
  # 'dev'   : unreleased
  # 'pre'   : pre-release Gem candidates
  #  nil    : released
  # You should never check in to trunk with this changed.  It should
  # stay 'dev'.  Change it to nil in release tags.
  RELEASE = 'dev' unless defined?(Bricklayer::RELEASE)
end