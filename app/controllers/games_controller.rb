class GamesController < ApplicationController
  respond_to :html
  before_filter :merge, :only => :create
  
  expose(:games){Game.order_by(params[:sort], params[:direction]).page(params[:page])}
  expose(:game)
  
  def create
    game.save
    respond_with(game)
  end
  
  def update
    game.save
    respond_with(game)
  end

  def destroy
    game.destroy
    respond_with(game)
  end
  
  def update_configuration
    @simulator = Simulator.find(params[:simulator_id])
    respond_to do |format|
      format.js {render "simulator_selector/update_configuration"}
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
    @game = Game.new_game_from_scheduler(params[:scheduler_id])
    respond_with(@game)
  end

  def calculate_cv_coefficients
    game.calculate_cv_coefficients
    respond_with(game)
  end

  def show
    respond_to do |format|
      format.html
      # come back and speed up sample issue
      format.xml { @profiles = game.display_profiles }
      format.json { @object = game; @granularity = params[:granularity]; @granularity ||= "summary"; @adjusted = params[:adjusted]; render "api/v3/games/show" }
    end
  end
  
  private 
  
  def merge
    params[:game] = params[:game].merge(params[:selector])
  end
end
