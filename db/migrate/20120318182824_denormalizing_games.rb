class DenormalizingGames < Mongoid::Migration
  def self.up
    Game.all.each do |game| 
      game.update_attribute(:simulator_fullname, game.simulator.fullname)
    end
  end

  def self.down
  end
end