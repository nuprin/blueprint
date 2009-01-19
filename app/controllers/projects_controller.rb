class ProjectsController < ApplicationController
  def all
    @projects = Project.active    
    render :action => "index"
  end

  def index
    @projects = Project.active.for_category(params[:category_id])
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    ignore_due_date_if_requested(params[:project])
    @project = Project.find(params[:id])
    @project.update_attributes(params[:project])
    @project.subscriptions.destroy_all
    (params[:user_ids] || []).each do |cc_id|
      @project.subscriptions.create(:user_id => cc_id)
    end
    flash[:notice] = "Your changes have been saved."
    redirect_to project_path(@project)
  end

  def update_category
    @project = Project.find(params[:id])
    @project.update_attribute(:category_id, params[:project][:category_id])
    render :text => @project.category_name
  end

  def update_title
    @project = Project.find(params[:id])
    @project.update_attribute(:title, params[:project][:title])
    render :text => @project.title
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
    redirect_to :back
  end
  
  def set_inactive
    project = Project.find(params[:id])
    project.update_attribute(:status, "inactive")
    flash[:notice] =
      "#{project.title} has been set to inactive. It will no longer show up " +
      " in the Projects menu or the Projects home page."
    redirect_to :back
  end

  def create
    @project = Project.create!(params[:project])
    flash[:notice] = "#{@project.title} has been created."
    redirect_to @project
  end
  
  def show
    @project = Project.find(params[:id])
  end  

  def completed
    @project = Project.find(params[:id])
  end  

  def parked
    @project = Project.find(params[:id])
  end
end