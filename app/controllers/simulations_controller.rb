class SimulationsController < ApplicationController
  respond_to :html
  
  expose(:simulations){Simulation.page(params[:page])}
  expose(:simulation)

end
