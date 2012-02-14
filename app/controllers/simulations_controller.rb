class SimulationsController < ApplicationController
  def destroy
    Simulation.failed.destroy_all
    redirect_to :action => :index
  end
end
