# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout 'monocle'
  helper :all

  def viewer
    return User.first
    @viewer = User.find_by_id(session[:user_id]) || User.new
  end
  helper_method :viewer
end
