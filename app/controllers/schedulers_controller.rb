class SchedulersController < ApplicationController
  expose(:schedulers){Scheduler.page(params[:page])}
  expose(:scheduler)
  expose(:profiles){scheduler.profiles.page(params[:page]).per(15)}
  
  def update_parameters
    @simulator = Simulator.find(params[:simulator_id])
    respond_to do |format|
      format.js {render "simulator_selector/update_parameters"}
    end
  end
end