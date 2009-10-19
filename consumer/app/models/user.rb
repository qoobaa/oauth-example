class User < ActiveRecord::Base
  validates_presence_of :login, :token, :secret
  validates_uniqueness_of :login

  def self.credentials
    { :key => "izXS0c1kE2BXd9Lt95sD", :secret => "VWhyk1HGE10iX8KhVhmt9wzSvHIGcS1BsMvdjswb", :options => { :site => "http://localhost:3000" } }
  end

  def self.consumer
    OAuth::Consumer.new(credentials[:key], credentials[:secret], credentials[:options])
  end

  def self.get_request_token(callback_url)
    consumer.get_request_token(:oauth_callback => callback_url)
  end

  def self.find_or_create_from_request_token(token, secret, oauth_verifier)
    request_token = OAuth::RequestToken.new(consumer, token, secret)
    options = {}
    options[:oauth_verifier] = oauth_verifier if oauth_verifier
    access_token = request_token.get_access_token(options)
    if access_token
      response = access_token.get("http://localhost:3000/account.json")
      login = JSON.parse(response.body)["user"]["login"] if (200...300).include?(response.code.to_i)
      find_or_initialize_by_login(login).tap do |user|
        user.token = access_token.token
        user.secret = access_token.secret
        user.save!
      end
    end
  end

  def client
    OAuth::AccessToken.new(self.class.consumer, token, secret)
  end

  def remote_attributes
    response = client.get("http://localhost:3000/account.json")
    if (200...300).include?(response.code.to_i)
      JSON.parse(response.body)["user"]
    else
      raise ActiveResource::ConnectionError
    end
  end

  def name
    remote_attributes["name"]
  end
end
