class SearchesController < ApplicationController
  def show
    q = params[:q]

    if q =~ /^\d+$/ && t = Task.find_by_id(q)
      redirect_to task_path(t)
    end

    if u = User.find_by_name(q)
      redirect_to u
    end
    
    if p = Project.find_by_title(q)
      redirect_to p
    end

    @results = Task.find_using_term(q).map(&:record)
  end
end
