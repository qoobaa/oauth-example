class User < ActiveRecord::Base
  acts_as_authentic
  has_many :client_applications
  has_many :tokens, :class_name => "OauthToken", :order=> "authorized_at desc", :include => [:client_application]
end
