class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @request_token = CvToken.get_request_token(create_user_session_url)
    session[:request_token_secret] = @request_token.secret
    if @request_token.callback_confirmed?
      redirect_to @request_token.authorize_url
    else
      redirect_to(@request_token.authorize_url + "&oauth_callback=#{create_user_session_url}")
    end
  end

  def create
    @request_token_secret = session.delete(:request_token_secret)
    if @request_token_secret
      @user = User.find_or_create_from_request_token(params[:oauth_token], @request_token_secret, params[:oauth_verifier])
      if @user
        session[:user_id] = @user.id
        flash[:notice] = "Login successful!"
        redirect_back_or_default root_path
      else
        flash[:error] = "An error happened, please try connecting again"
        redirect_to root_path
      end
    end
  end

  def destroy
    session.delete(:user_id)
    flash[:notice] = "Logout successful!"
    redirect_back_or_default root_path
  end
end
