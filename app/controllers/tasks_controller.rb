class TasksController < ApplicationController
  before_filter :find_model

  def create
    raise "You don't exist" unless viewer.real?
    begin
      task = Task.create!(params[:task])
    rescue ActiveRecord::RecordInvalid
      flash[:notice] = "Please be sure to include a title."
      render :action => "new"
      return
    end
    flash[:notice] = "&ldquo;#{task.title}&rdquo; created."
    if params[:commit] == "Create and Add Another"
      redirect_to new_task_url(params[:task])
    elsif task.project_id
      redirect_to project_url(task.project_id)
    elsif task.assignee_id
      redirect_to user_url(task.assignee_id)
    else
      redirect_to tasks_url
    end
  end

  def quick_create
    task = Task.create!(params[:task].merge(:creator_id => viewer.id))
    context = params[:context]
    if context == "User"
      li = TaskListItem.for_context(viewer).first(:conditions => {
        :task_id => task.id
      })
    else
      li = TaskListItem.for_context(task.project).first(:conditions => {
        :task_id => task.id
      })
    end
    render :partial => "/shared/task", :locals => {
      :task_list_item_or_task => (li || task),
      :context => context
    }    
  end

  def new
    @task = Task.new
  end

  def edit; end
  
  def update
    @task.update_attributes(params[:task])
    flash[:notice] = "Your changes have been saved."
    redirect_to task_url(@task)
  end

  def complete
    @task.complete!
    redirect_to :back
  end

  def park
    @task.park!
    flash[:notice] = "The task &ldquo;#{@task.title}&rdquo; has been parked."
    redirect_to :back
  end

  def prioritize
    @task.prioritize!
    flash[:notice] =
      "The task &ldquo;#{@task.title}&rdquo; has been prioritized."
    redirect_to :back
  end

  def destroy
    @task.destroy
    flash[:notice] =
      "The task &ldquo;#{@task.title}&rdquo; has been deleted."
    if request.env["HTTP_REFERER"].include?(task_path(@task.id))
      if @task.project_id
        redirect_to project_url(@task.project_id)
      else
        redirect_to user_url(@task.assignee_id)
      end
    else
      redirect_to :back
    end
  end

  def reorder
    list_item = TaskListItem.find(params[:list_item_id])
    list_item.update_position(params[:list_item_position])
    render :text => {:status => "ok"}.to_json
  rescue ActiveRecord::RecordNotFound
    render :text => {:status => "item not found"}.to_json
  end

  def show
    @comment = Comment.new(:task_id => params[:id], :author_id => viewer.id)
  end

  private

  def find_model
    @task = Task.find(params[:id]) if params[:id]
  end

end
