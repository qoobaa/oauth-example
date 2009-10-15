require "oauth/request_proxy/action_controller_request"
require "oauth/server"

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation

  private

  # AUTHLOGIC

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to account_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # OAUTH

  # def current_token
  #   @current_token
  # end

  # def current_token=(token)
  #   @current_token = token
  #   if @current_token
  #     # @current_user = @current_token.user
  #     @current_client_application = @current_token.client_application
  #   end
  #   @current_token
  # end

  def current_token
    return @current_token if defined?(@current_token)
    token = nil

    valid = ClientApplication.verify_request(request) do |request_proxy|
      token = ClientApplication.find_token(request_proxy.token)
      if token
        token.provided_oauth_verifier = request_proxy.oauth_verifier if token.respond_to?(:provided_oauth_verifier=)
        [token.secret, token.client_application.secret]
      end
    end

    @current_token = token if valid
  end

  def current_client_application
    return @current_client_application if defined?(@current_client_application)
    if current_token
      @current_client_application = current_token.client_application
    end
  end

  # use in a before_filter
  def require_oauth
    if verify_oauth_access_token
      true
    else
      invalid_oauth_response
    end
  end

  def require_oauth_or_user
    if verify_oauth_access_token
      true
    else
      require_user
    end
  end

  def verify_oauth_request_token
    current_token && current_token.is_a?(::RequestToken)
  end

  def verify_oauth_access_token
    current_token && current_token.is_a?(::AccessToken)
  end

  def invalid_oauth_response(code = 401, message = "Invalid OAuth Request")
    render :text => message, :status => code
  end

  # verifies a request token request
  def verify_oauth_consumer_signature
    valid = ClientApplication.verify_request(request) do |request_proxy|
      @current_client_application = ClientApplication.find_by_key(request_proxy.consumer_key)

      if @current_client_application
        @current_client_application.token_callback_url = request_proxy.oauth_callback if request_proxy.oauth_callback
        [nil, @current_client_application.secret]
      end
    end
    invalid_oauth_response unless valid
  end
end
