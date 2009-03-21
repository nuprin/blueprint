class TaskListItemsController < ApplicationController
  def move_to_top
    tli = TaskListItem.find(params[:id])
    tli.move_to_top
    flash[:notice] =
      "The task &ldquo;#{tli.task.title}&rdquo; is now a top priority."
    redirect_to :back
  end
end
