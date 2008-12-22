class TaskSubscriptionsController < ApplicationController
  def create
    begin
      ts = TaskSubscription.create!(params[:task_subscription])
      render :partial => "/tasks/task_subscription_name", :locals => {:ts => ts}      
    rescue ActiveRecord::RecordInvalid
      render :text => ""
    end
  end

  def destroy
    sub = TaskSubscription.find(params[:id])
    sub.destroy
    flash[:notice] =
      "You have been unsubscribed from receiving emails about this task."
    redirect_to task_path(sub.task_id)
  end
end
