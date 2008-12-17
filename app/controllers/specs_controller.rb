class SpecsController < ApplicationController
  def show
    @spec = Spec.find(params[:id])
    @project = @spec.project
    redirect_to edit_project_spec_path(@project, @spec) if @spec.body.blank?
  end

  def edit
    @spec = Spec.find(params[:id])
    @project = @spec.project
  end

  def update
    spec = Spec.find(params[:id])
    spec.update_attribute(:body, params[:spec][:body])
    flash[:notice] = "Your changes have been saved."
    redirect_to project_spec_path(spec.project_id, spec)
  end
end
