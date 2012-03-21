class Api::V2::BaseController < ActionController::Base
  respond_to :json
  before_filter :authenticate_user!
  
  def index
    respond_with(params[:controller].classify.demodulize.constantize.all)
  end
  
  def show
    @object = params[:controller].classify.demodulize.constantize.find(params[:id])
    respond_with(@object)
  end
  
end