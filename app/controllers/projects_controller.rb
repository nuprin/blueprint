class ProjectsController < ApplicationController
  layout 'blueprint'

  def index
    @projects = Project.active
  end

  def new
    @project = Project.new
  end

  def set_active
    project = Project.find(params[:id])
    project.update_attribute(:status, "active")
    flash[:notice] =
      "#{project.title} is now an active project. It has been added to the " +
      "Projects menu and the Projects home page."
    redirect_to project
  end
  
  def set_inactive
    project = Project.find(params[:id])
    project.update_attribute(:status, "inactive")
    flash[:notice] =
      "#{project.title} has been set to inactive. It will no longer show up " +
      " in the Projects menu or the Projects home page."
    redirect_to project
  end

  def create
    @project = Project.create!(params[:project])
    flash[:notice] = "#{@project.title} has been created."
    redirect_to @project
  end
  
  def show
    @project = Project.find(params[:id])
  end
end