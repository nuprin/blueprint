class SearchesController < ApplicationController
  def show
    q = params[:q]

    if q =~ /^\d+$/
      t = Task.find_by_id(params[:q])
      redirect_to task_path(t) and return if t
    end

    @results = Task.find_using_term(q).map(&:record)
  end
end
