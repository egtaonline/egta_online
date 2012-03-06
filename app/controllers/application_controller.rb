class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  expose(:model_name){params[:controller].singularize}
  protect_from_forgery
end
