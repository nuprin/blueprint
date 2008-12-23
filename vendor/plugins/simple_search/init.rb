require File.dirname(__FILE__) + "/lib/active_search"
ActiveRecord::Base.send(:include, ActiveSearch)