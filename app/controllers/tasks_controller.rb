class TasksController < ApplicationController
  before_filter :find_model

  def create
    render :text => params.to_json
  end

  def index
    @projects = Project.all # TODO: only show active projects
  end

  def new

  end

  def reorder
    # TODO: update the model with this new data
    params[:list_item_id]
    params[:list_item_position]
    render :text => "ok"
  end

  def show

  end

  private

  def find_model
    @task = Task.find(params[:id]) if params[:id]
  end

end