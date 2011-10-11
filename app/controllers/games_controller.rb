class GamesController < EntitiesController
  include SimulatorSelectorController
  include StrategyController
  
  def show
    respond_to do |format|
      format.html
      # come back and speed up sample issue
      format.xml { @profiles = Profile.where(:proto_string => @entry.strategy_regex, :_id.in => @entry.profile_ids, :payoff_avgs.exists => true).to_a }
    end
  end
end
