class CreateTheSetOfSimulatorInstances < Mongoid::Migration
  def self.up
    Simulator.all.each do |simulator|
      simulator.schedulers.distinct(:configuration).each do |config|
        SimulatorInstance.create!(simulator_id: simulator.id, configuration: config)
      end
    end
  end

  def self.down
  end
end