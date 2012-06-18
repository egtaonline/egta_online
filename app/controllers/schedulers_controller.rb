class SchedulersController < ApplicationController
  respond_to :html, :json
  before_filter :merge, :only => [:create, :update]
  
  # These exposures are so that we can treat all different schedulers as scheduler in views, allowing view reuse where it's helpful
  expose(:schedulers){model_name.classify.constantize.order_by(params[:sort], params[:direction]).page(params[:page])}
  expose(:scheduler) do
    proxy = model_name.classify.constantize
    if id = params["#{model_name}_id"] || params[:id]
      proxy.find(id).tap do |r|
        r.attributes = params[model_name] unless request.get?
      end
    else
      proxy.new(params[model_name])
    end
  end
  
  expose(:profiles){scheduler.profiles.order_by(params[:sort], params[:direction]).page(params[:page])}

  def create
    scheduler.save
    respond_with(scheduler)
  end

  def update
    scheduler.save
    respond_with(scheduler)
  end

  def destroy
    scheduler.destroy
    respond_with(scheduler)
  end

  def page_profiles
  end

  def create_game_to_match
    respond_with(scheduler.create_game_to_match)
  end

  def update_configuration
    @simulator = Simulator.find(params[:simulator_id])
    respond_to do |format|
      format.js {render "simulator_selector/update_configuration"}
    end
  end
  
  private 
  
  def merge
    params[model_name] = params[model_name].merge(params[:selector])
  end
end