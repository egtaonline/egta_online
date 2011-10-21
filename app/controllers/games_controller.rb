class GamesController < EntitiesController
  include SimulatorSelectorController
  include StrategyController
  before_filter :simulators, only: "new"
  
  def add_role
    resource.add_role(role, params[:role_count])
    redirect_to resource_url
  end
  
  def show
    respond_to do |format|
      format.html
      # come back and speed up sample issue
      format.xml { @profiles = Profile.where(:proto_string => resource.strategy_regex, :_id.in => resource.profile_ids, :payoff_avgs.exists => true).to_a }
      format.json { @profiles = Profile.where(:proto_string => resource.strategy_regex, :_id.in => resource.profile_ids, :payoff_avgs.exists => true).to_a }
    end
  end
end
