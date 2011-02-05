class HomeController < ApplicationController

#  def index
#    @clean_sample_count = Sample.find_all_by_clean(true).count
#    @sample_count = Sample.count
#    @active_simulation_count = Simulation.active.count
#    @complete_simulation_count = Simulation.complete.count
#    @active_scheduler_count = GameScheduler.active.count + ProfileScheduler.active.count + DeviationScheduler.active.count
#    @scheduler_count = GameScheduler.count + ProfileScheduler.count + DeviationScheduler.count
#  end

  def index
    @clean_sample_count = -1
    @sample_count = -1
    @active_simulation_count = -1
    @complete_simulation_count = -1
    @active_scheduler_count = -1
    @scheduler_count = -1
  end
end
