class Api::V3::GamesController < Api::V3::BaseController
  before_filter :find_game, only: [:show, :add_role, :add_strategy, :remove_role, :remove_strategy]
  before_filter :validate_role, only: [:add_role, :add_strategy, :remove_role, :remove_strategy]
  before_filter :validate_strategy, only: [:add_strategy, :remove_strategy]
  before_filter :validate_role_count, only: [:add_role]

  include Api::V3::RoleManipulator

  def add_role
    if @game.roles.where(name: params[:role]).count > 0
      respond_with(@game, status: 304)
    else
      @game.add_role(params[:role], params[:count].to_i)
      respond_with(@game)
    end
  end

  def add_strategy
    if @game.roles.where(name: params[:role]).count == 0
      if params[:count] == nil || params[:count] == "" || params[:count].to_i == 0
        respond_with({error: "you did not specify a count for this role"}, status: 422, location: nil)
      else
        @game.add_role(params[:role], params[:count].to_i)
        @game.reload
      end
    end
    if @game.roles.where(name: params[:role]).first.strategies.include?(params[:strategy]) == false
      @game.add_strategy(params[:role], params[:strategy])
      respond_with(@game)
    else
      respond_with(@game, status: 304)
    end
  end

  def remove_role
    if @game.roles.where(name: params[:role]).count == 0
      respond_with({message: "the role did not exist"}, status: 204, location: nil)
    else
      @game.remove_role(params[:role])
      respond_with(@game, status: 202)
    end
  end

  def remove_strategy
    if @game.roles.where(name: params[:role]).count == 0
      respond_with({error: "the role did not exist"}, status: 404, location: nil)
    elsif @game.roles.where(name: params[:role]).first.strategies.include?(params[:strategy]) == false
      respond_with({message: "the role did not exist"}, status: 204, location: nil)
    else
      @game.remove_strategy(params[:role], params[:strategy])
      respond_with(@game)
    end
  end

  def index
    render json: "{games:#{Game.collection.find.select(name: 1, simulator_fullname: 1, configuration: 1, size: 1).to_json}}", status: 200
  end

  def show
    render json: GamePresenter.new(@game).to_json(granularity: params[:granularity]), status: 200
  end

  protected

  def validate_role_count
    if params[:count] == nil || params[:count] == "" || params[:count].to_i == 0
      respond_with({error: "you did not specify a count for this role"}, status: 422, location: nil)
    end
  end

  def find_game
    begin
      @game = Game.find(params[:id])
    rescue
      render json: {error: "the game you were looking for could not be found"}.to_json, status: 404
    end
  end
end