class SearchesController < ApplicationController
  def show
    q = params[:q]

    if q =~ /^\d+$/
      t = Task.find_by_id(params[:q])
      redirect_to task_url(t) and return if t
    end

    search_results = [Project, Task].map do |model|
      [model.name, model.find_using_term(q).map(&:record)]
    end
    @all_results = Hash[*search_results.flatten(1)]
  end
end
