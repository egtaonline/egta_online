class GamesController < EntitiesController
  include SimulatorSelectorController
  include StrategyController
  before_filter :simulators, only: "new"
  
  def show
    respond_to do |format|
      format.html
      # come back and speed up sample issue
      format.xml { @profiles = Profile.where(:proto_string => resource.strategy_regex("All"), :_id.in => resource.profile_ids, :payoff_avgs.exists => true).to_a }
      format.json { @profiles = Profile.where(:proto_string => resource.strategy_regex("All"), :_id.in => resource.profile_ids, :payoff_avgs.exists => true).to_a }
    end
  end
end
