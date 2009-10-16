ActionController::Routing::Routes.draw do |map|
  map.resource :account, :controller => "users"
  map.resource :user_session, :member => { :create => :get }
  map.resources :oauth_consumers, :collection => { :callback => :get }
  map.root :controller => "home", :action => "show"
end
