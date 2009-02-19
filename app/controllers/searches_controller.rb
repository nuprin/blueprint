class SearchesController < ApplicationController

  def show
    q = params[:q]

    if q == "bugs"
      redirect_to bugs_path
    end
    
    if q =~ /^\d+$/ && t = Task.find_by_id(q)
      redirect_to task_path(t)
    end

    if u = User.find_by_name(q)
      redirect_to u
    end
    
    if p = Project.find_by_title(q)
      redirect_to p
    end

    @results = Ultrasphinx::Search.new(:query => q, :per_page => 50).
                results.sort_by do |item|
      case item
      when Initiative: 0
      when Task: 1
      end
    end
  end

end
