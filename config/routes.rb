ActionController::Routing::Routes.draw do |map|
  map.resources :tasks

  map.root :controller => "tasks", :action => "index"

  map.resources :users,
                :collection => {:login => :get,
                                :save_login => :post}
  map.resources :tasks,
                :collection => {:reorder => :post}

end
