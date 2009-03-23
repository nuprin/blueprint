class ProjectListItemsController < ApplicationController
  def reorder
    li = ProjectListItem.find(params[:id])
    li.insert_at(params[:position])
    render :text => {:status => "ok"}.to_json
  rescue ActiveRecord::RecordNotFound
    render :text => {:status => "item not found"}.to_json
  end
end
