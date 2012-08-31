class Api::V3::SimulatorsController < Api::V3::BaseController
  before_filter :find_simulator, only: [:add_role, :add_strategy, :remove_role, :remove_strategy]
  before_filter :validate_role, only: [:add_role, :add_strategy, :remove_role, :remove_strategy]
  before_filter :validate_strategy, only: [:add_strategy, :remove_strategy]

  include Api::V3::RoleManipulator

  def index
    render json: "{simulators:#{Simulator.collection.find.select(name: 1, version: 1).to_json}}", status: 200
  end

  def show
    begin
      render json: Simulator.collection.find(_id: Moped::BSON::simulatorId(params[:id])).select(name: 1, version: 1, configuration: 1, 'roles.name' => 1, 'roles.strategies' => 1).to_json, status: 200
    rescue
      render json: {error: "the simulator you were looking for could not be found"}.to_json, status: 404
    end
  end

  def add_role
    if @simulator.roles.where(name: params[:role]).count > 0
      respond_with(@simulator, status: 304)
    else
      @simulator.add_role(params[:role])
      respond_with(@simulator)
    end
  end

  def add_strategy
    if @simulator.roles.where(name: params[:role]).count == 0 || @simulator.roles.where(name: params[:role]).first.strategies.include?(params[:strategy]) == false
      @simulator.add_strategy(params[:role], params[:strategy])
      respond_with(@simulator)
    else
      respond_with(@simulator, status: 304)
    end
  end

  def remove_role
    if @simulator.roles.where(name: params[:role]).count == 0
      respond_with({message: "the role did not exist"}, status: 204, location: nil)
    else
      @simulator.remove_role(params[:role])
      respond_with(@simulator, status: 202)
    end
  end

  def remove_strategy
    if @simulator.roles.where(name: params[:role]).count == 0
      respond_with({error: "the role did not exist"}, status: 404, location: nil)
    elsif @simulator.roles.where(name: params[:role]).first.strategies.include?(params[:strategy]) == false
      respond_with({message: "the role did not exist"}, status: 204, location: nil)
    else
      @simulator.remove_strategy(params[:role], params[:strategy])
      respond_with(@simulator)
    end
  end

  private

  def find_simulator
    begin
      @simulator = Simulator.find(params[:id])
    rescue
      render json: {error: "the simulator you were looking for could not be found"}.to_json, status: 404
    end
  end
end