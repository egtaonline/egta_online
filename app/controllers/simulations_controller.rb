class SimulationsController < ApplicationController
  respond_to :html, :json
  
  expose(:simulations){Simulation.order_by(params[:sort], params[:direction]).page(params[:page])}
  expose(:simulation)

end
