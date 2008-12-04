ActionController::Routing::Routes.draw do |map|
  map.resources :tasks

  map.root :controller => "tasks", :action => "index"

  map.resources :tasks,
                :collection => {:reorder => :post}

end
