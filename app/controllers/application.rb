# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout 'monocle'
  helper :all

  before_filter :require_login

  def viewer
    @viewer = User.find_by_id(session[:user_id]) || User.new
  end
  helper_method :viewer

  def require_login
    redirect_to login_users_url unless viewer.real?
  end
end
