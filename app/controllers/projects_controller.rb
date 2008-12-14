class ProjectsController < ApplicationController
  layout 'blueprint'
  # TODO: only show active projects
  def index
    @projects = Project.all 
  end

  def new
    @project = Project.new
  end
  
  def create
    @project = Project.create!(params[:project])
    flash[:notice] = "#{@project.title} has been created."
    redirect_to project_url(@project)
  end
  
  def show
    @project = Project.find(params[:id])
  end
end