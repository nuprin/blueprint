class DeferredTasksController < ApplicationController
  def create
    parse_custom_time
    begin
      dt = DeferredTask.create!(params[:deferred_task])
      flash[:notice] = "The task will be parked until " +
        "#{dt.prioritize_at.getlocal.strftime("%b %e at %I:%M%p")}."
    rescue ActiveRecord::RecordInvalid
      flash[:notice] =
        "There was an error in parking your task. Please try again."
    end
    redirect_to :back
  end
  
  private

  def parse_custom_time
    if params[:deferred_task][:prioritize_at] == "custom"
      t = params[:custom_time]
      params[:deferred_task][:prioritize_at] = Chronic.parse(t).getutc
    end
  end
end
