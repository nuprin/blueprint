class CommentsController < ApplicationController
  skip_before_filter :require_login, :only => :create
  def create
    begin
      comment = Comment.create!(params[:comment])
      flash[:notice] = "Your comment has been created. You will also receive " +
                       "email notifications about future changes to this task."
    rescue ActiveRecord::RecordInvalid
      flash[:notice] = "Your comment must have either text or photo."
    end
    if params[:redirect_url]
      redirect_to params[:redirect_url]
    else
      render :text => "Success"
    end
  end

  def destroy
    comment = Comment.find(params[:id])
    comment.destroy
    flash[:notice] = "Your comment has been deleted."
    redirect_to :back
  end
end
