class DeferredTasksController < ApplicationController
  def create
    begin
      parse_custom_time
      dt = DeferredTask.create!(params[:deferred_task])
      flash[:notice] =
        "The task will be parked until #{dt.friendly_prioritize_at}."
    rescue ActiveRecord::RecordInvalid
      flash[:notice] =
        "There was an error in parking your task. Please try again."
    rescue => ex
      flash[:notice] = ex.message
    end
    redirect_to :back
  end
  
  def destroy
    dt = DeferredTask.find(params[:id])
    dt.destroy
    flash[:notice] = "This task has been parked indefinitely."
    redirect_to task_path(dt.task_id)
  end

  private

  def parse_custom_time
    if params[:deferred_task][:prioritize_at] == "custom"
      t = params[:custom_time]
      parsed_time = Chronic.parse(t)
      if parsed_time
        params[:deferred_task][:prioritize_at] = parsed_time.getutc
      else
        raise "Sorry, I don't understand what &ldquo;#{params[:custom_time]}" +
          "&rdquo;  means."
      end
    end
  end
end
