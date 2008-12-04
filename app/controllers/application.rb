# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout 'monocle'
  helper :all

  helper_method :viewer
  def viewer
    User.first
  end

  #protect_from_forgery
end
