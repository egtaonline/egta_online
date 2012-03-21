class Api::V2::BaseController < ActionController::Base
  respond_to :json
  before_filter :authenticate_user!, :fullness
  
  def index
    @collection = params[:controller].classify.demodulize.constantize.all
    respond_with(@collection)
  end
  
  def show
    @object = params[:controller].classify.demodulize.constantize.find(params[:id])
    respond_with(@object)
  end
  
  protected
  
  def fullness
    @full = params[:full]
  end
end