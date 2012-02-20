class SimulationsController < ApplicationController
  respond_to :html
  
  expose(:simulations){Simulation.page(params[:page])}
  expose(:simulation)
  
  def destroy
    Simulation.failed.destroy_all
    redirect_to :action => :index
  end
end
