class DeliverablesController < TasksController
  def update
    @task.update_attributes(params[:deliverable])
    flash[:notice] = "Your changes have been saved."
    redirect_to task_path(@task)
  end
end