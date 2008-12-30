# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout 'blueprint'
  helper :all

  before_filter :require_login

  private

  def viewer
    @viewer = User.find_by_id(session[:user_id]) || User.new
  end
  helper_method :viewer

  def require_login
    redirect_to login_users_path unless viewer.real?
  end

  def ignore_due_date_if_requested(object_hash)
    if params[:use_due_date].to_i == 0
      1.upto(3) do |i|
        object_hash["due_date(#{i}i)"] = ""
      end
    end
  end
end
