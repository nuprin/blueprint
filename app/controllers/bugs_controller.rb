class BugsController < ApplicationController
  def index
    @tasks = Task.prioritized.bugs
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
