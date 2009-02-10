class BugsController < ApplicationController
  def index
    @tasks = Task.prioritized.all(:conditions => {:kind => "bug"})
  end

  def completed
    @tasks = Task.completed.all(:conditions => {:kind => "bug"})
    render :action => "index"
  end

  def parked
    @tasks = Task.parked.all(:conditions => {:kind => "bug"})
    render :action => "index"
  end
end
