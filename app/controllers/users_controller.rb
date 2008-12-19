class UsersController < ApplicationController
  before_filter :require_login, :except => [:login, :save_login]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def you
    redirect_to viewer
  end

  def login; end

  def save_login
    user = User.find(params[:user_id])
    session[:user_id] = user.id
    redirect_to ''
  rescue ActiveRecord::RecordNotFound
    redirect_to login_users_path
  end
end
