class ConsumerToken < ActiveRecord::Base
  validates_presence_of :token, :secret

  def self.service_name
    @service_name ||= self.to_s.underscore.scan(/^(.*?)(_token)?$/)[0][0].to_sym
  end

  def self.consumer
    @consumer ||= OAuth::Consumer.new(credentials[:key], credentials[:secret], credentials[:options])
  end

  def self.get_request_token(callback_url)
    consumer.get_request_token(:oauth_callback => callback_url)
  end

  def self.find_or_create_from_request_token(token, secret, oauth_verifier)
    request_token = OAuth::RequestToken.new(consumer, token, secret)
    options = {}
    options[:oauth_verifier] = oauth_verifier if oauth_verifier
    access_token = request_token.get_access_token(options)
    find_or_create_by_token_and_secret(access_token.token, access_token.secret)
  end

  def client
    @client ||= OAuth::AccessToken.new(self.class.consumer, token, secret)
  end

  protected

  def self.credentials
    @credentials ||= OAUTH_CREDENTIALS[service_name]
  end
end
