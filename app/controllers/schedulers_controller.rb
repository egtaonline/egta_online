class SchedulersController < ApplicationController
  respond_to :html
  
  expose(:schedulers){Scheduler.page(params[:page])}
  expose(:scheduler)
  expose(:profiles){scheduler.profiles.page(params[:page]).per(15)}

  def create
    @scheduler = Scheduler.new(params[:scheduler].merge(params[:selector]))
    @scheduler.save
    respond_with(@scheduler)
  end

  def update
    scheduler.save
    respond_with(scheduler)
  end

  def destroy
    scheduler.destroy
    respond_with(scheduler)
  end

  def update_parameters
    @simulator = Simulator.find(params[:simulator_id])
    respond_to do |format|
      format.js {render "simulator_selector/update_parameters"}
    end
  end
end