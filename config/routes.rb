ActionController::Routing::Routes.draw do |map|

  map.resources :projects

  map.resources :tasks,
                :member => {:complete => :post, :undo_complete => :post},
                :collection => {:people => :get, :reorder => :post}

  map.resources :users,
                :collection => {:login => :get, :save_login => :post}
  map.root :controller => "projects", :action => "index"

end
