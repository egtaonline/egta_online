class CreateTheSetOfSimulatorInstances < Mongoid::Migration
  class ::Simulator
    has_many :schedulers
  end

  class ::Scheduler
    belongs_to :simulator
    field :configuration, type: Hash
  end

  def self.up
    SimulatorInstance.destroy_all
    Simulator.all.each do |simulator|
      simulator.schedulers.distinct(:configuration).each do |config|
        SimulatorInstance.create!(simulator_id: simulator.id, configuration: config)
      end
    end
  end

  def self.down
  end
end