class CommentsController < ApplicationController
  def create
    comment = Comment.create!(params[:comment])
    flash[:notice] = "Your comment has been created."
    redirect_to task_path(comment.task_id)
  end
  def destroy
    comment = Comment.find(params[:id])
    comment.destroy
    flash[:notice] = "Your comment has been deleted."
    redirect_to task_path(comment.task_id)
  end
end