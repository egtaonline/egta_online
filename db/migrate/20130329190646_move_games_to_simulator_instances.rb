class MoveGamesToSimulatorInstances < Mongoid::Migration
  class ::Game
    belongs_to :simulator
    field :configuration, type: Hash
  end

  def self.up
    Game.all.each do |game|
      old_count = game.profiles.count
      simulator_instance = SimulatorInstance.find_or_create_by(simulator_id: game.simulator_id, configuration: game.configuration)
      game.update_attributes(simulator_instance_id: simulator_instance.id)
      new_count = game.reload.profiles.count
      if old_count == new_count
        game.unset(:simulator_id)
        game.unset(:configuration)
      else
        puts 'failed #{game.name} #{simulator_instance.id}'
      end
    end
  end

  def self.down
  end
end