class TasksController < ApplicationController
  before_filter :find_model

  def create
    raise "You don't exist" unless viewer.real?
    ignore_due_date_if_requested
    begin
      task =
        Task.create_with_subscriptions!(params[:task], params[:cc] || [])
    rescue ActiveRecord::RecordInvalid
      @task = Task.new(params[:task])
      flash[:notice] = "Please be sure to include a title."
      render :action => "new"
      return
    end
    flash[:notice] = "&ldquo;#{task.title}&rdquo; created."
    if params[:commit] == "Create and Add Another"
      redirect_to new_task_path(:task => params[:task])
    elsif task.project_id
      redirect_to task.project
    elsif task.assignee_id
      redirect_to task.assignee
    else
      redirect_to task_path(task)
    end
  end

  def quick_create
    task = Task.create!(params[:task])
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
    @task = Task.new(params[:task])
  end

  def edit; end
  
  def update
    ignore_due_date_if_requested
    @task.update_attributes(params[:task])
    flash[:notice] = "Your changes have been saved."
    redirect_to task_path(@task)
  end

  def complete
    if params[:final_comment] && !params[:final_comment][:text].blank?
      Comment.create!(params[:final_comment])
    end
    create_followup_task_if_requested
    @task.complete!
    flash[:notice] = "The task &ldquo;#{@task.title}&rdquo; has been marked " +
                     "complete."
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
        redirect_to @task.project
      else
        redirect_to @task.assignee
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

  def create_followup_task_if_requested
    if params[:followup].to_i == 1
      Task.create!(params[:followup_task])
    end
  end

  # TODO [chris]: There must be a way to get this in the model.
  def ignore_due_date_if_requested
    if params[:use_due_date].to_i == 0
      1.upto(3) do |i|
        params[:task]["due_date(#{i}i)"] = ""
      end
    end
  end

  def find_model
    @task = Task.find(params[:id]) if params[:id]
  end

end
