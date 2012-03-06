class GamesController < ApplicationController
  respond_to :html
  before_filter :merge, :only => :create
  
  expose(:games){Game.page(params[:page])}
  expose(:game)
  
  def create
    game.save
    respond_with(game)
  end
  
  def destroy
    game.destroy
    respond_with(game)
  end
  
  def update_parameters
    @simulator = Simulator.find(params[:simulator_id])
    respond_to do |format|
      format.js {render "simulator_selector/update_parameters"}
    end
  end

  def add_role
    game.add_role(params[:role], params[:role_count])
    respond_with(game)
  end

  def add_strategy
    game.add_strategy(params[:role], params["#{params[:role]}_strategy"])
    respond_with(game)
  end

  def remove_role
    game.remove_role(params[:role])
    respond_with(game)
  end
  
  def remove_strategy
    game.remove_strategy(params[:role], params[:strategy_name])
    respond_with(game)
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
      format.xml { @profiles = game.display_profiles }
      format.json { @profiles = game.display_profiles }
    end
  end
  
  def show_with_samples
    respond_to do |format|
      format.json { render :json => resource, :root => params[:egat] == "true" }
    end
  end
  
  private 
  
  def merge
    params[:game] = params[:game].merge(params[:selector])
  end
end
