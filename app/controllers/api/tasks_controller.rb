class Api::TasksController < ApplicationController
  skip_before_filter :require_login
  before_filter :set_task, :only => [ :show, :comment, :comments, :mark_complete ]
  # GET /api/tasks
  # GET /api/tasks.xml
  def index
    task = build_task_from_options(params)
    conditions = task_to_conditions(task)
    @tasks = Task.find(:all, :conditions => conditions).each do |task| 
      add_task_data(task)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
      format.json { render :json => @tasks }
    end
  end

  # GET /api/tasks/1
  # GET /api/tasks/1.xml
  def show
    @task = add_task_data(@task)
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
    @task = build_task_from_options(params)
    @task.prioritize!
    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        format.html { redirect_to(@task) }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
        format.json { render :json => @task, :status => :created, :location => @task }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
        format.json { render :json => @task.errors, :status => :unprocessable_entity }
      end
    end
  end
#
#  # PUT /api/tasks/1
#  # PUT /api/tasks/1.xml
  def update
    @task = build_task_from_options(params)
    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully updated.'
#        format.html { redirect_to(@task) }
        format.xml  { head :ok }
      else
#        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end
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

  # GET /api/tasks/comments/id
  # GET /api/tasks/comments/id.xml
  # GET /api/tasks/comments/id.json
  def comments
    @comments = @task.comments
    # Also need to add a username mapping to all the comments so the client
    # knows who wrote the comment. (instead of just an id)
    @comments.each do |comment|
      comment['author_name'] = User.find(comment.author_id).name
    end

    respond_to do |format|
      format.xml  { render :xml => @comments}
      format.json { render :json => @comments}
    end
  end

  # POST /api/tasks/comment/id
  def comment
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
      :commentable => @task
    )

    @task.editor = author

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

    if @task.status != 'completed'
      if !params[:comment].blank? && author
        Comment.create!(
          :author => author,
          :text => params[:comment],
          :commentable => @task
        )
      end

      @task.editor = author
      @task.complete!
    end

    respond_to do |format|
      format.xml  { head status, :message => message }
      format.json { head status, :message => message }
    end
  end

  private
  def add_task_data(task)
    task[:author_email] = task.creator.email if task.creator
    task[:assignee_email] = task.assignee.email if task.assignee
    task[:project_title] = task.project.title if task.project

    task
  end

  # PARAMS:
  # takes all params a task can use to create a new one
  # in addition, it can accept
  # author_email as a string
  # user as a string
  def build_task_from_options(options={})
    if options[:id]
      task = Task.find(options[:id])
    else
      task = Task.new
    end
    user = nil

    # Find the assigned user to this task
    if options[:author_email]
      author = User.find_by_email(options[:author_email])
      task.creator_id = author.id
    end

    if options[:assignee_email]
      assignee = User.find_by_email(options[:assignee_email])
      task.assignee_id = assignee.id
    end

    if options[:due_date]
      task.due_date = Date.parse(options[:due_date])
      options.delete(:due_date)
    end

    task_to_conditions(task, :include_nil => true).each do |attr, val|
      attr = attr.to_sym
      task[attr] = options[attr] if options.include?(attr)
    end
    task
  end

  def task_to_conditions(task, options={})
    conditions = {}
    attributes = task.attributes
    if options[:include_nil].blank?
      attributes = attributes.select { |key, val| !val.blank? }
    end

    attributes.each do |key, val|
      conditions[key] = val
    end
    conditions
  end

  protected
  def set_task
    @task = Task.find(params[:id])
  end

  # use http authentication instead of the regular cookie stuff
  def require_login
    authenticate_or_request_with_http_basic do |username, password|
      username == "blueprint-api-client" && password == "callipygian"
    end
  end
end
