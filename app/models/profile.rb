# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document

  embedded_in :game
  embeds_many :players
  has_many :simulations

  def scheduled_count
    game.simulations.scheduled.where(:profile_id => self.id).reduce{|sum, sim| sum + sim.samples.count}.to_f + players.first.payoffs.count
  end

  def size
    players.size
  end

  def contains_strategy?(name)
    players.where(:strategy => name).count != 0
  end

  def strategy_array
    players.collect{|player| player.strategy}
  end

  def name
    strategy_array.join(", ")
  end

  def payoff_to_strategy(strategy)
    pay = 0.0
    players.where(:strategy => strategy).each {|x| pay += x.payoffs.count == 0 ? 0 : x.payoffs.avg(:payoff)}
    pay /= players.where(:strategy => strategy).count
  end

  before_destroy :kill_simulations

  def kill_simulations
    game.simulations.where(:profile_id => self.id).destroy_all
  end
end
