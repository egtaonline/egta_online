class MovingSchedulersToSimulatorInstance < Mongoid::Migration
  class ::Scheduler
    belongs_to :simulators
    field :configuration, type: Hash
  end

  def self.up
    Scheduler.where(:simulator_id.exists => true, :configuration.exists => true).each do |scheduler|
      simulator_instance = SimulatorInstance.find_or_create_by(simulator_id: scheduler.simulator_id, configuration: scheduler.configuration)
      scheduler.update_attributes(simulator_instance_id: simulator_instance.id)
      scheduler.unset(:simulator_id)
      scheduler.unset(:configuration)
    end
    Simulator.all.unset(:scheduler_ids)
    Simulator.all.unset(:game_ids)
  end

  def self.down
  end
end