class Api::V3::BaseController < ActionController::Base
  respond_to :json
  before_filter :authenticate_user!
  before_filter :granularity, :find_object, :only => :show
  
  def index
    @collection = params[:controller].classify.demodulize.constantize.all
    respond_with(@collection)
  end
  
  def show
    puts "CALLED"
    respond_with(@object)
  end
  
  protected
  
  def granularity
    @granularity = params[:granularity]
    if @granularity != "observation" && @granularity != "full"
      @granularity = "summary"
    end
  end
  
  def find_object
    begin
      @object = params[:controller].classify.demodulize.constantize.find(params[:id])
    rescue
      render :json => {:error => "the #{params[:controller].classify.demodulize.tableize.singularize} you were looking for could not be found"}.to_json, :status => 404
    end
  end
end