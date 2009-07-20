class Api::ProjectsController < ApplicationController
  skip_before_filter :require_login
  # GET /api/projects
  # GET /api/projects.xml
  #
  # PARAMS: status is one of (active, inactive, completed)
  def index
    conditions = {}
    conditions[:status] = params[:status] if params[:status]
    @projects = Project.find(:all, :conditions => conditions)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
      format.json { render :json => @projects }
    end
  end
end

