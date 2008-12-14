class ProjectsController < ApplicationController
  layout 'blueprint'
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