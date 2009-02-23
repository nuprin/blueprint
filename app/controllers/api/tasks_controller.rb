class Api::TasksController < ApplicationController
  # GET /api/tasks
  # GET /api/tasks.xml
  def index
    @tasks = Task.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  # GET /api/tasks/1
  # GET /api/tasks/1.xml
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
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
#  # POST /api/tasks
#  # POST /api/tasks.xml
#  def create
#    @task = Task.new(params[:task])
#
#    respond_to do |format|
#      if @task.save
#        flash[:notice] = 'Task was successfully created.'
#        format.html { redirect_to(@task) }
#        format.xml  { render :xml => @task, :status => :created, :location => @task }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
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
#    @task.destroy
#
#    respond_to do |format|
#      format.html { redirect_to(api/tasks_url) }
#      format.xml  { head :ok }
#    end
#  end

  def mark_complete
    task = Task.find(params[:id])
    author = User.find_by_email(params[:author_email])

    if !params[:comment].blank? && author
      Comment.create!(
        :author => author,
        :text => params[:comment],
        :commentable => task
      )
    end

    task.editor = author
    task.complete!

    respond_to do |format|
      format.xml  { head :ok }
    end
  end

  protected

  # use http authentication instead of the regular cookie stuff
  def require_login
    authenticate_or_request_with_http_basic do |username, password|
      username == "blueprint-api-client" && password == "callipygian"
    end
  end
end
