class SearchesController < ApplicationController
  def show
    begin
      t = Task.find(params[:q])
      redirect_to task_path(t)
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Please search for a specific task number."
      redirect_to ""
    end
  end
end