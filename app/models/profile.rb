# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document

  embedded_in :game
  embeds_many :players
  embeds_many :simulations


  def scheduled_count
    counter = Simulation.scheduled.where(:profile_id => self.id).inject(0) {|result, element| result + element.size}
    counter ||= 0
    self.samples.count+counter
  end

  def contains_strategy?(strategy_name)
    if players.detect {|x| x.strategy == strategy_name}
      return true
    end
    return false
  end

  def strategy_array
    pl = self.players.collect{|x| x.strategy}
    pl.sort
  end

  def strategy_array=(array)
    array.each{|x| self.players.create(:strategy => x)}
  end

  def name
    strategy_array.join(", ")
  end
end
