class CommentsController < ApplicationController
  def create
    comment = Comment.create!(params[:comment])
    flash[:notice] = "Your comment has been created. You will also receive " +
                     "email notifications about future changes to this task."
    redirect_to params[:redirect_url]
  end

  def destroy
    comment = Comment.find(params[:id])
    comment.destroy
    flash[:notice] = "Your comment has been deleted."
    redirect_to :back
  end  
end
