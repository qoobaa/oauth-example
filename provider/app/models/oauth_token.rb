class OauthToken < ActiveRecord::Base
  belongs_to :client_application
  belongs_to :user
  validates_uniqueness_of :token
  validates_presence_of :client_application, :token, :secret
  before_validation_on_create :generate_keys

  named_scope :valid, :conditions => { :invalidated_at => nil }

  def invalidated?
    invalidated_at != nil
  end

  def invalidate!
    update_attribute(:invalidated_at, Time.now)
  end

  def authorized?
    authorized_at != nil && !invalidated?
  end

  def to_query
    "oauth_token=#{token}&oauth_token_secret=#{secret}"
  end

  def self.find_token(token_key)
    token = find_by_token(token_key, :include => :client_application)
    if token && token.authorized?
      token
    else
      nil
    end
  end

  protected

  def generate_keys
    oauth_token = client_application.oauth_server.generate_credentials
    self.token = oauth_token[0][0,20]
    self.secret = oauth_token[1][0,40]
  end
end
