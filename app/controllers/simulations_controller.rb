class SimulationsController < EntitiesController
  def purge
    Simulation.failed.destroy_all
    redirect_to :action => :index
  end
end
