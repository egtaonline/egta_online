class GamesController < SimulatorSelectorController
  include StrategyController

  def add_role
    resource.add_role(role, params[:role_count])
    redirect_to resource_url
  end

  def add_feature
    resource.features.create(params)
    redirect_to resource_url
  end

  def remove_feature
    puts params
    resource.features.where(:name => params[:name]).destroy
    redirect_to resource_url
  end

  def from_scheduler
    scheduler = Scheduler.find(params[:scheduler_id])
    @game = Game.new_game_from_scheduler(scheduler)
    if @game.save!
      @game.add_roles_from_scheduler(scheduler)
      redirect_to game_url(@game)
    else
      render "new"
    end
  end

  def show
    respond_to do |format|
      format.html
      # come back and speed up sample issue
      format.xml { @profiles = Profile.where(:proto_string => resource.strategy_regex, :_id.in => resource.profile_ids, :sampled => true).to_a }
      format.json { @profiles = Profile.where(:proto_string => resource.strategy_regex, :_id.in => resource.profile_ids, :sampled => true).to_a }
    end
  end
  
  def show_with_samples
    respond_to do |format|
      format.json { @profiles = Profile.where(:proto_string => resource.strategy_regex, :_id.in => resource.profile_ids, :sampled => true).to_a }
    end
  end
end
