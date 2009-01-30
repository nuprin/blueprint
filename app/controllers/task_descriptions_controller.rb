class TaskDescriptionsController < ApplicationController
  def edit_all
    @tasks = viewer.undescribed_tasks
  end
  
  def update_all
    params[:tasks].each do |id, attributes|
      t = Task.find(id)
      t.update_attributes(attributes)
    end
    flash[:notice] = "Your changes have been saved."
    redirect_to user_path(viewer)
  end
end
