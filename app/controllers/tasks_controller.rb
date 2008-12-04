class TasksController < ApplicationController
  before_filter :find_model

  def create
    Task.create!(params[:task])
    redirect_to tasks_url
  end

  def index
    @projects = Project.all # TODO: only show active projects
  end

  def new
    @task = Task.new
  end

  def reorder
    # TODO: update the model with this new data
    params[:list_item_id]
    params[:list_item_position]
    render :text => {:status => "ok"}.to_json
  end

  def show

  end

  private

  def find_model
    @task = Task.find(params[:id]) if params[:id]
  end

end