class Api::TasksController < ApplicationController
  skip_before_filter :require_login
  # GET /api/tasks
  # GET /api/tasks.xml
  def index
    task = build_task_from_options(params)
    conditions = task_to_conditions(task)
    @tasks = Task.find(:all, :conditions => conditions)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
      format.json { render :json => @tasks }
    end
  end

  # GET /api/tasks/1
  # GET /api/tasks/1.xml
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
      format.json { render :json => @task }
    end
  end

#  # GET /api/tasks/new
#  # GET /api/tasks/new.xml
#  def new
#    @task = Task.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @task }
#    end
#  end
#
#  # GET /api/tasks/1/edit
#  def edit
#    @task = Task.find(params[:id])
#  end
#
  # POST /api/tasks
  # POST /api/tasks.xml
  # POST /api/tasks.json
  def create
    task = build_task_from_options(params)
    attributes = task_to_conditions(task) # this allows for supplying user by name

    @task = Task.new(params[:task].merge(attributes))

    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        format.html { redirect_to(@task) }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end
#
#  # PUT /api/tasks/1
#  # PUT /api/tasks/1.xml
#  def update
#    @task = Task.find(params[:id])
#
#    respond_to do |format|
#      if @task.update_attributes(params[:task])
#        flash[:notice] = 'Task was successfully updated.'
#        format.html { redirect_to(@task) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#  # DELETE /api/tasks/1
#  # DELETE /api/tasks/1.xml
#  def destroy
#    @task = Task.find(params[:id])
#
#    @task.destroy
#
#    respond_to do |format|
#      format.html { redirect_to(api/tasks_url) }
#      format.xml  { head :ok }
#    end
#  end
#

  def comment
    task = Task.find(params[:id])
    status = :ok
    message = ""

    if params[:author_email]
      author = User.find_by_email(params[:author_email])
    elsif params[:user]
      author = User.find_by_name(params[:user])
    else
      # TODO: Error out if no one is marked as closing this task.
      status = :bad_request
    end

    Comment.create!(
      :author => author,
      :text => params[:text],
      :commentable => task
    )

    task.editor = author

    respond_to do |format|
      format.xml  { head status, :message => message }
      format.json { head status, :message => message }
    end
  end

  # PARAMS:
  # req: id => task id
  # opt: comment => text
  # opt: author_email => author's email address
  # opt: user => user's name
  #
  # either author_email or user is required
  def mark_complete
    task = Task.find(params[:id])
    status = :ok
    message = ""

    if params[:author_email]
      author = User.find_by_email(params[:author_email])
    elsif params[:user]
      author = User.find_by_name(params[:user])
    else
      # TODO: Error out if no one is marked as closing this task.
      status = :bad_request
    end

    if task.status != 'completed'
      if !params[:comment].blank? && author
        Comment.create!(
          :author => author,
          :text => params[:comment],
          :commentable => task
        )
      end

      task.editor = author
      task.complete!
    end

    respond_to do |format|
      format.xml  { head status, :message => message }
      format.json { head status, :message => message }
    end
  end

  protected

  # use http authentication instead of the regular cookie stuff
  def require_login
    authenticate_or_request_with_http_basic do |username, password|
      username == "blueprint-api-client" && password == "callipygian"
    end
  end

  private

  # PARAMS:
  #   user_name - supply a string (GET/POST)
  #   status - completed, parked or prioritized (GET/POST)
  #   project_id - supply an id (GET/POST)
  #   date - due date of task (POST)
  #   hours - hours (POST)
  def build_task_from_options(options={})
    t = Task.new
    if options[:user]
      user = User.find_by_name(options[:user])
      t.assignee_id = user.id
    end

    if options[:status]
      t.status = options[:status]
    end

    if options[:project_id]
      project = Project.find(options[:project_id])
      t.project_id = project.id
    end

    if options[:date]
      date = Time.parse(date)
      t.due_date = date
    end

    t
  end

  def task_to_conditions(task)
    conditions = {}
    attributes = task.attributes.select { |key, val| !val.blank? }
    attributes.each do |key, val|
      conditions[key] = val
    end
    conditions
  end
end
