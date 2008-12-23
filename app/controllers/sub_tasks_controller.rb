class SubTasksController < TasksController
  def update
    @task.update_attributes(params[:sub_task])
    flash[:notice] = "Your changes have been saved."
    redirect_to task_path(@task)
  end
end