class SubscriptionsController < ApplicationController
  def create
    begin
      sub = Subscription.create!(params[:subscription])
      locals = {:sub => sub}
      render :partial => "/tasks/task_subscription_name", :locals => locals
    rescue ActiveRecord::RecordInvalid
      render :text => ""
    end
  end

  def destroy
    sub = Subscription.find(params[:id])
    sub.destroy
    flash[:notice] =
      "You have been unsubscribed from receiving emails about this task."
    redirect_to task_path(sub.entity_id)
  end
end
