class GamesController < ApplicationController
  respond_to :html
  before_filter :merge, only: :create

  expose(:games){ Game.order_by("#{sort_column} #{sort_direction}").page(params[:page]) }
  expose(:game)
  expose(:profile_counts){ game.profile_counts }

  def create
    game = Game.create_with_simulator_instance(params[:game])
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

  def calculate_cv_coefficients
    game.calculate_cv_coefficients
    respond_with(game)
  end

  def show
    respond_to do |format|
      format.html
      format.json { send_data GamePresenter.new(game).to_json(granularity: params[:granularity]), type: 'text/json', filename: "#{game.id}.json" }
    end
  end

  private

  def merge
    params[:game] = params[:game].merge(params[:selector])
  end

  def default
    "name"
  end
end