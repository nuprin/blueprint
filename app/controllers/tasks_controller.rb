class TasksController < ApplicationController
  before_filter :find_model

  def create
    raise "You don't exist" unless viewer.real?
    ignore_due_date_if_requested(params[:task])
    begin
      @task =
        Task.create_with_subscriptions!(params[:task], params[:cc] || [])
    rescue ActiveRecord::RecordInvalid
      @task = Task.new(params[:task])
      flash[:notice] = "Please be sure to include a title."
      render :action => "new"
      return
    end
    flash[:notice] = "&ldquo;#{@task.title}&rdquo; created."
    if params[:commit] == "Create and Add Another"
      redirect_to new_task_path(:task => params[:task])
    elsif @task.project_id
      redirect_to @task.project
    elsif @task.assignee_id
      redirect_to @task.assignee
    else
      redirect_to task_path(@task)
    end
  end

  def quick_create
    task = Task.new(params[:task])
    # Rails quirk: For security reasons, type cannot be assigned in create or
    # update_attribute calls.
    task.type = params[:task][:type]
    task.save!
    task.mass_mailer.ignoring(task.creator).deliver_task_creation
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
    @task.assignee_id = viewer.id
  end

  def edit; end
  
  def update
    ignore_due_date_if_requested(params[:task])
    begin
      @task.update_attributes!(params[:task])
      flash[:notice] = "Your changes have been saved."
      redirect_to task_path(@task)
    rescue ActiveRecord::RecordInvalid
      render :action => "edit"
    end
  end

  def update_assignee
    params[:task][:assignee_id] = nil if params[:task][:assignee_id].blank?
    @task.update_attribute(:assignee_id, params[:task][:assignee_id])
    if @task.assignee_id
      user_path = user_path(@task.assignee_id)
      link = "<a href='#{user_path}'>#{@task.assignee.name}</a>"
    else
      link = ""
    end
    render :text => link
  end

  def update_project
    params[:task][:project_id] = nil if params[:task][:project_id].blank?
    @task.update_attribute(:project_id, params[:task][:project_id])
    if @task.project_id
      project_path = project_path(@task.project_id)
      link = "<a href='#{project_path}'>#{@task.project.title}</a>"
    else
      link = ""
    end
    render :text => link
  end

  def update_title
    @task.update_attribute(:title, params[:task][:title])
    task_path = task_path(@task)
    link = "<a href='#{task_path}'>#{@task.title}</a>"
    render :text => link
  end

  def update_type
    @task.update_attribute(:type, params[:task][:type])
    # Reload from the db so that it's aware of its new type.
    @task = Task.find(@task.id)
    render :partial => "/shared/task", :locals => {
      :task_list_item_or_task => @task,
      :context => params[:context]
    }
  end

  def update_estimate
    hours = params[:task][:estimate].gsub(/hours?/, "").strip
    @task.update_attributes!(:estimate => hours)
    render :text => "#{@task.estimate} hours"
  end

  def update_due_date
    due_date = Date.parse(params[:task][:due_date])
    @task.update_attributes!(:due_date => due_date)
    render :text => due_date.strftime("%b %e")
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
    referer = request.env["HTTP_REFERER"]
    if referer && referer.include?(task_path(@task.id))
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
  end

  private

  def create_followup_task_if_requested
    if params[:followup].to_i == 1
      task = Task.create!(params[:followup_task])
      if params[:subscriptions]
        task.subscriptions.create params[:subscriptions].values
      end
    end
  end

  def find_model
    @task = Task.find(params[:id]) if params[:id]
    @task.editor = viewer if viewer.real? && @task
  end

end
