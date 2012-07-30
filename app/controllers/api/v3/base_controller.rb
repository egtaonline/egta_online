class Api::V3::BaseController < ActionController::Base
  respond_to :json
  before_filter :authenticate_user!, :fullness
  before_filter :find_object, :only => :show
  
  def index
    @collection = params[:controller].classify.demodulize.constantize.all
    respond_with(@collection)
  end
  
  def show
    respond_with(@object)
  end
  
  protected
  
  def fullness
    @full = params[:full]
  end
  
  def find_object
    begin
      @object = params[:controller].classify.demodulize.constantize.find(params[:id])
    rescue
      render :json => {:error => "the #{params[:controller].classify.demodulize.tableize.singularize} you were looking for could not be found"}.to_json, :status => 404
    end
  end
end