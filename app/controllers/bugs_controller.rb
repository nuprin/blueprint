class BugsController < ApplicationController
  def index
    @tasks = Bug.task_list
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
