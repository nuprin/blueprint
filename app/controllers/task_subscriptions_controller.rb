class TaskSubscriptionsController < ApplicationController
  def create
    
    cc = params[:task_subscription]
    user = User.find_by_id(cc['user_id']) || 
          User.find_by_name(cc['user_name'])
    sub = TaskSubscription.create(:task_id => cc['task_id'],
                             :user => user) 
    render :text =>
      "<span class='cc' id='cc_#{sub.id}'>#{user.name} " +
      "<span class='remove_link'>(Remove)</span></span>"
  end
  def destroy
    sub = TaskSubscription.find_by_id(params[:id])
    sub.destroy if sub
    render :text => 'ok'
  end
end
