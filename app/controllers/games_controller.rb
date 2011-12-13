class GamesController < SimulatorSelectorController
  include StrategyController

  def add_role
    resource.add_role(role, params[:role_count])
    redirect_to resource_url
  end

  def from_scheduler
    puts params
    scheduler = Scheduler.find(params[:scheduler_id])
    @game = Game.new(name: scheduler.name, size: scheduler.size, simulator_id: scheduler.simulator_id, parameter_hash: scheduler.parameter_hash)
    if @game.save!
      scheduler.roles.each {|r| @game.roles.create!(name: r.name, count: r.count); r.strategy_array.each{|s| @game.add_strategy_by_name(r.name, s)}}
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
end
