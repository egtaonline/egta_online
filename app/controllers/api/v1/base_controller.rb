class Api::V1::BaseController < ActionController::Base
  respond_to :json
  before_filter :authenticate_user!
  
  def index
    respond_with(params[:controller].classify.demodulize.constantize.all)
  end
  
  def show
    respond_with(params[:controller].classify.demodulize.constantize.find(params[:id]))
  end
end