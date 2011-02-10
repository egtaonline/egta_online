# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document

  embedded_in :game, :inverse_of => :profiles
  embeds_many :players
  references_many :simulations, :inverse_of => :profile

  def scheduled_count
    counter = game.simulations.scheduled.where(:profile_id => self.id).size == 0 ? 0 : game.simulations.scheduled.where(:profile_id => self.id).sum(:size)
    counter += game.simulations.complete.where(:profile_id => self.id).size == 0 ? 0 : game.simulations.complete.where(:profile_id => self.id).sum(:size)
  end

  scope :contains_strategy, lambda{|strategy_name| where(strategy_name.to_sym.gt => 0)}

  def size
    players.size
  end

  def strategy_array
    strat = Array.new
    players.each {|x| strat.concat([x.strategy])}
    strat.sort
  end

  def strategy_array=(array)
    array.each do |x|
      self.players.create(:strategy => x)
      y = x.tr(".", "|")
      if self[y] == nil || self[y] == 0
        self[y] = 1
      else
        self[y] = self[y]+1
      end
    end
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
    simulations.destroy_all
  end
end
