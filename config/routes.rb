ActionController::Routing::Routes.draw do |map|
  map.resources :features

  map.resources :comments
  map.resource  :company
  map.resources :deliverables
  map.resources :git
  map.resources :projects, :member => {
                  :completed => :get,
                  :parked => :get,
                  :set_active   => :put,
                  :set_inactive => :put,
                } do |projects|
                  projects.resource :specification
                end
  map.resource  :search
  map.resources :sub_tasks
  map.resources :subscriptions
  map.resources :tasks,
                :member => {
                  :complete => :post,
                  :park => :post,
                  :prioritize => :post,
                  :update_assignee => :put,
                  :update_description => :put,
                  :update_due_date => :put,
                  :update_estimate => :put,
                  :update_project => :put,
                  :update_status => :put,
                  :update_title => :put,
                  :update_type => :put
                },
                :collection => {
                  :people => :get,
                  :quick_create => :post,
                  :reorder => :post
                }
  map.resources :users,
                :member => {
                  :completed => :get,
                  :created => :get,
                  :parked => :get,
                  :subscribed => :get
                },
                :collection => {
                  :login => :get,
                  :save_login => :post
                }
  map.root :controller => "users", :action => "you"
  map.connect ':controller/:action/:id'
end
