class SchedulersController < ApplicationController
  respond_to :html
  before_filter :merge, :only => [:create, :update]
  
  expose(:schedulers){Scheduler.page(params[:page])}
  expose(:scheduler)
  expose(:profiles){scheduler.profiles.page(params[:page])}

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

  def update_parameters
    @simulator = Simulator.find(params[:simulator_id])
    respond_to do |format|
      format.js {render "simulator_selector/update_parameters"}
    end
  end
  
  private 
  
  def merge
    params[:scheduler] = params[:scheduler].merge(params[:selector])
  end
end