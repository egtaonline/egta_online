class Api::V3::GamesController < Api::V3::RoleManipulator
  before_filter :find_game, only: :show
  before_filter :validate_role_count, only: :add_role
  before_filter :add_role_for_strategy, only: :add_strategy

  def index
    render json: "{\"games\":#{Game.collection.find.select(name: 1, simulator_fullname: 1, configuration: 1, size: 1).to_json}}", status: 200
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

  def add_role_for_strategy
    if @subject.roles.where(name: params[:role]).count == 0
      @subject.add_role(params[:role], params[:count].to_i)
      @subject.reload
    end
  end
end