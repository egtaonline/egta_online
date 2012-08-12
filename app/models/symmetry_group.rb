class SymmetryGroup
  include Mongoid::Document
  
  embedded_in :profile
  embeds_many :players
  
  field :count, type: Integer
  field :role
  field :strategy
  
  validates :count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :role, presence: true
  validates :strategy, presence: true, uniqueness: { scope: :role }
  
  def payoff_for(observation_id)
    payoffs_in_observation = players.where(observation_id: observation_id).collect{ |player| player.payoff }
    if payoffs_in_observation.count > 0
      payoffs_in_observation.reduce(:+).to_f/payoffs_in_observation.count
    else
      "FAIL"
    end
  end
  
  def payoff
    if players.count > 0
      players.map{ |player| player.payoff }.reduce(:+).to_f/players.count
    end
  end
  
  def payoff_sd
    if players.count > 0
      Math.sqrt(players.map{ |player| player.payoff**2.0 }.reduce(:+).to_f/players.count-payoff**2.0)
    end
  end
end