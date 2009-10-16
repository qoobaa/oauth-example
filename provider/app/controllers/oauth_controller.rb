class OauthController < ApplicationController
  before_filter :require_user, :only => [:authorize, :revoke]
  before_filter :require_oauth_or_user, :only => [:test_request]
  before_filter :require_oauth, :only => [:invalidate, :capabilities]
  before_filter :verify_oauth_request_token, :only => [:access_token]

  def request_token
    @token = current_client_application.create_request_token
    if @token
      render :text => @token.to_query
    else
      head :unauthorized
    end
  end

  def access_token
    @token = current_token && current_token.exchange!
    if @token
      render :text => @token.to_query
    else
      head :unauthorized
    end
  end

  # Handles GET (renders form) and POST (usually redirects) - probably
  # might be decoupled
  def authorize
    @token = RequestToken.valid.find_by_token params[:oauth_token]
    if @token
      if request.post?
        if params.has_key?(:authorize)
          @token.authorize!(current_user)
          @redirect_url = @token.oob? ? @token.client_application.callback_url : @token.callback_url

          if @redirect_url
            redirect_to "#{@redirect_url}?oauth_token=#{@token.token}&oauth_verifier=#{@token.verifier}"
          else
            render :action => "authorize_success"
          end
        else
          @token.invalidate!
          render :action => "authorize_failure"
        end
      end

      # EXPERIMENTAL - QUICK AUTHENTICATION
      if request.get? and AccessToken.exists?(:user_id => current_user.id, :client_application_id => @token.client_application_id, :invalidated_at => nil)
        @token.authorize!(current_user)
        @redirect_url = @token.oob? ? @token.client_application.callback_url : @token.callback_url

        if @redirect_url
          redirect_to "#{@redirect_url}?oauth_token=#{@token.token}&oauth_verifier=#{@token.verifier}"
        else
          render :action => "authorize_success"
        end
      end
    else
      render :action => "authorize_failure"
    end
  end

  # Additional stuff begins here - may be moved
  def revoke
    @token = current_user.tokens.find_by_token params[:token]

    if @token
      @token.invalidate!
      flash[:notice] = "You've revoked the token for #{@token.client_application.name}"
    end

    redirect_to oauth_clients_url
  end

  def test_request
    head :ok
  end

  # Invalidate current token
  def invalidate
    current_token.invalidate!
    head :gone
  end

  # Capabilities of current_token
  def capabilities
    if current_token.respond_to?(:capabilities)
      @capabilities = current_token.capabilities
    else
      @capabilities = { :invalidate => url_for(:action => :invalidate) }
    end

    respond_to do |format|
      format.json { render :json => @capabilities }
      format.xml { render :xml => @capabilities }
    end
  end
end
