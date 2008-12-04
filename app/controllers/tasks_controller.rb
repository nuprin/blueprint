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
    params[:list_item_id]
    params[:list_item_position]
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
