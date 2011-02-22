#Updates application statistics in the view
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :checkup

  def checkup
    # @sample_count = 0
    # Simulation.complete.each {|x| @sample_count += x.samples.count}
    # @active_simulation_count = Simulation.active.count
    # @complete_simulation_count = Simulation.complete.count
    # @active_scheduler_count = GameScheduler.active.count + ProfileScheduler.active.count + DeviationScheduler.active.count
    # @scheduler_count = GameScheduler.count + ProfileScheduler.count + DeviationScheduler.count
  end
end
