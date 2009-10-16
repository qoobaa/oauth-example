ActionController::Routing::Routes.draw do |map|
  map.resource :account, :controller => "users"
  map.resources :oauth_consumers, :collection => { :callback => :get }
  map.root :controller => "home", :action => "show"
end
