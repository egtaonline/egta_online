class SimulatorDescendentsController < AnalysisController
  before_filter :find_simulator

  protected

  def find_simulator
    if params[:simulator_id] == nil
      params[:simulator_id] = Simulator.first.id
    end
    @simulator = Simulator.find(params[:simulator_id])
  end

end