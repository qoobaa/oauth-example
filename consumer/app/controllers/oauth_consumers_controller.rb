class OauthConsumersController < ApplicationController
  # before_filter :load_consumer, :except => :index
  skip_before_filter :verify_authenticity_token, :only => :callback

  # def index
  #   @consumer_tokens = ConsumerToken.all
  #   @services = OAUTH_CREDENTIALS.keys - @consumer_tokens.collect { |c| c.class.service_name }
  # end

  # def show
  #   unless @token
  #     @request_token = @consumer.get_request_token(callback_oauth_consumer_url(params[:id]))
  #     session[@request_token.token] = @request_token.secret
  #     if @request_token.callback_confirmed?
  #       redirect_to @request_token.authorize_url
  #     else
  #       redirect_to(@request_token.authorize_url + "&oauth_callback=#{callback_oauth_consumer_url(params[:id])}")
  #     end
  #   end
  # end

  def callback
    session["request_token_secrets"] ||= {}
    @request_token_secret = session["request_token_secrets"][params[:oauth_token]]
    session.delete("request_token_secrets")
    if @request_token_secret
      @cv_token = CvToken.find_or_create_from_request_token(params[:oauth_token], @request_token_secret, params[:oauth_verifier])
      @user = User.find_or_create_by_cv_token(@cv_token)
      if @user
        session[:user_id] = @user.id
        flash[:notice] = "#{params[:id].humanize} was successfully connected to your account"
        redirect_to root_path
      else
        flash[:error] = "An error happened, please try connecting again"
        redirect_to root_path
      end
    end
  end

  # def destroy
  #   throw RecordNotFound unless @token
  #   @token.destroy
  #   if params[:commit]=="Reconnect"
  #     redirect_to oauth_consumer_url(params[:id])
  #   else
  #     flash[:notice] = "#{params[:id].humanize} was successfully disconnected from your account"
  #     redirect_to root_url
  #   end
  # end

  protected

  # def load_consumer
  #   consumer_key = params[:id].to_sym
  #   throw RecordNotFound unless OAUTH_CREDENTIALS.include?(consumer_key)
  #   @consumer = "#{consumer_key.to_s.camelcase}Token".constantize
  #   @token = @consumer.last
  #   # find_by_user_id current_user.id
  # end
end
