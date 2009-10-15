ActionController::Routing::Routes.draw do |map|
  map.resources :oauth_consumers, :member => { :callback => :get }
  map.root :controller => "oauth_consumers", :action => "index"
end
