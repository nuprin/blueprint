ActionController::Routing::Routes.draw do |map|

  map.root :controller => "tasks", :action => "index"

  map.resources :tasks,
                :collection => {:people => :get, :reorder => :post}

end
