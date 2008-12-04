class TasksController < ApplicationController
  before_filter :find_model

  def index

  end

  def new

  end

  def show

  end

  private

  def find_model
    @task = Task.find(params[:id]) if params[:id]
  end

end