ActionController::Routing::Routes.draw do |map|
  map.namespace(:api) do |api|
    api.resources :tasks, :member => {
      :mark_complete => :put
    }
  end

  map.namespace(:admin) do |admin|
    admin.resources :users
  end

  map.resources :bugs, :collection => {
    :completed => :get,
    :parked => :get
  }
  map.resources :comments
  map.resources :deferred_tasks
  map.resources :deliverables
  map.resources :features
  map.resources :git
  map.resources :project_list_items,
                :member => {
                  :reorder => :put
                }
  map.resources :projects, :member => {
                  :completed => :get,
                  :parked => :get,
                  :set_active   => :put,
                  :set_inactive => :put,
                  :update_category => :put,
                  :update_title => :put
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
  map.resources :task_descriptions,
                :collection => {
                  :edit_all => :get,
                  :update_all => :get
                }
  map.resources :task_list_items,
                :member => {
                  :move_to_top => :put
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
