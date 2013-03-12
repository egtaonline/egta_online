class Api::V3::SimulatorsController < Api::V3::RoleManipulatorController
  def index
    render json: "{\"simulators\":#{Simulator.collection.find.select(name: 1, version: 1).to_json}}", status: 200
  end

  def show
    begin
      render json: Simulator.collection.find(_id: Moped::BSON::simulatorId(params[:id])).select(name: 1, version: 1, configuration: 1, 'roles.name' => 1, 'roles.strategies' => 1).to_json, status: 200
    rescue
      render json: {error: "the simulator you were looking for could not be found"}.to_json, status: 404
    end
  end
end