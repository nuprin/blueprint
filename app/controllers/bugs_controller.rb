class BugsController < ApplicationController
  def index
    @task_list_items = Bug.task_list
    @tasks = @task_list_items.map(&:task)
  end

  def completed
    @tasks = Task.completed.bugs
    render :action => "index"
  end

  def parked
    @tasks = Task.parked.bugs
    render :action => "index"
  end
end
