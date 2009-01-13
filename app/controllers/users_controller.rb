class UsersController < ApplicationController
  before_filter :require_login, :except => [:login, :save_login]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def subscribed
    @user = User.find(params[:id])
    @tasks = filtered_task_list(:subscribed_tasks)
  end

  def created
    @user = User.find(params[:id])
    @tasks = filtered_task_list(:created_tasks)
  end

  def parked
    @user = User.find(params[:id])
    @tasks = @user.tasks.parked
  end
  
  def completed
    @user = User.find(params[:id])
    @tasks_by_day = @user.tasks_completed_by_day
  end

  def you
    redirect_to viewer
  end

  def login; end

  def save_login
    user = User.find(params[:user_id])
    session[:user_id] = user.id
    redirect_to user_path(user)
  rescue ActiveRecord::RecordNotFound
    redirect_to login_users_path
  end
  
  private
  
  def filtered_task_list(task_method)
    if params[:status]
      @user.send(task_method).send(params[:status]).first(100)
    else
      params[:status] = "all"
      @user.send(task_method).first(100)
    end
  end
end
