class SpecificationsController < ApplicationController
  def show
    @spec = Specification.find(params[:id])
    @project = @spec.project
    if @spec.body.blank?
      redirect_to edit_project_specification_path(@project, @spec) 
    end
  end

  def edit
    @spec = Specification.find(params[:id])
    @project = @spec.project
  end

  def update
    spec = Specification.find(params[:id])
    spec.update_attribute(:body, params[:spec][:body])
    flash[:notice] = "Your changes have been saved."
    redirect_to project_specification_path(spec.project_id, spec)
  end
end
