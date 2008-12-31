class SpecificationsController < ApplicationController
  def show
    @project = Project.find(params[:project_id])
    @spec = @project.specification
    if @spec.body.blank?
      redirect_to edit_project_specification_path(@project) 
    end
  end

  def edit
    @project = Project.find(params[:project_id])
    @spec = @project.specification
  end

  def update
    spec = Specification.find_by_project_id(params[:project_id])
    spec.update_attribute(:body, params[:spec][:body])
    flash[:notice] = "Your changes have been saved."
    redirect_to project_specification_path(params[:project_id])
  end
end
