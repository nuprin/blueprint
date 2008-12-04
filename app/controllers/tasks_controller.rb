class TasksController < ApplicationController
  before_filter :find_model

  def create
    raise "You don't exist" unless viewer.real?
    Task.create!(params[:task].merge(:creator_id => viewer.id))
    redirect_to tasks_url
  end

  def index
    @projects = Project.all # TODO: only show active projects
  end

  def people
    @users = User.all
    @projects = Project.all # TODO: only show active projects
  end

  def new
    @task = Task.new
  end

  def reorder
    list_item = TaskListItem.find(params[:list_item_id])
    list_item.update_position(params[:list_item_position])
    render :text => {:status => "ok"}.to_json
  rescue ActiveRecord::RecordNotFound
    render :text => {:status => "item not found"}.to_json
  end

  def show

  end

  private

  def find_model
    @task = Task.find(params[:id]) if params[:id]
  end

end
