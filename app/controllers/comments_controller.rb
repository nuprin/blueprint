class CommentsController < ApplicationController
  def create
    comment = Comment.create!(params[:comment])
    flash[:notice] = "Your comment has been created."
    redirect_to comment.task
  end
  def destroy
    comment = Comment.find(params[:id])
    comment.destroy
    flash[:notice] = "Your comment has been deleted."
    redirect_to comment.task
  end
end
