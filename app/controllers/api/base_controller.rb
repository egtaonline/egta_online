class Api::BaseController < ActionController::Base
  respond_to :json
  
  before_filter :authenticate_user
  
  private
  
  def authenticate_user
    @current_user = User.where(:authentication_token => params[:token]).first
    unless @current_user
      respond_with({:error => "Token is invalid."})
    end
  end
  
  def current_user
    @current_user
  end
end