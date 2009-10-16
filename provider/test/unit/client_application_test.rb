require File.dirname(__FILE__) + '/../test_helper'

class ClientApplicationTest < ActiveSupport::TestCase
  fixtures :users, :client_applications, :oauth_tokens

  def setup
    @application = ClientApplication.create(
      :name => "Agree2",
      :url  => "http://agree2.com",
      :user => users(:quentin)
    )
    @consumer = OAuth::Consumer.new(
      @application.key, @application.secret,
      :site => @application.oauth_server.base_url
    )
  end

  def test_should_be_valid
    assert @application.valid?
  end


  def test_should_not_have_errors
    assert @application.errors.empty?
  end

  def test_should_have_key_and_secret
    assert_not_nil @application.key
    assert_not_nil @application.secret
  end

  def test_should_have_credentials
    assert_not_nil @application.credentials
    assert_equal @application.key, @application.credentials.key
    assert_equal @application.secret, @application.credentials.secret
  end

  def test_should_find_token_by_token_key
    @token = @application.create_request_token
    @token.authorize!(users(:quentin))
    assert ClientApplication.find_token(@token.token)
  end

  def test_should_not_find_token_by_invalid_token_key
    assert_nil ClientApplication.find_token("")
  end

  def test_should_not_find_not_authorized_token
    @token = @application.create_request_token
    assert_nil ClientApplication.find_token(@token.token)
  end

  # TODO
  def test_should_verify_request
  end

  def test_should_create_valid_request_token
    @token = @application.create_request_token
    assert @token
    assert @token.valid?
  end

end
