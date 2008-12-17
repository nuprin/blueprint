ActionController::Routing::Routes.draw do |map|

  map.resources :projects,
                :member => {
                  :set_active   => :put,
                  :set_inactive => :put,
                  # TODO [chris]: This is a nested resource.
                  :spec         => :get, 
                  :update_spec  => :put
                }
  map.resources :comments
  map.resources :tasks,
                :member => {
                  :complete => :post,
                  :park => :post,
                  :prioritize => :post
                },
                :collection => {
                  :people => :get,
                  :quick_create => :post, 
                  :reorder => :post
                }

  map.resources :users,
                :collection => {:login => :get, :save_login => :post}
  map.root :controller => "users", :action => "you"

end
