class SymmetryGroup
  include Mongoid::Document
  
  embedded_in :role_strategy_partitionable, polymorphic: true
  embeds_many :players
  
  accepts_nested_attributes_for :players
  
  field :count, type: Integer
  field :role
  field :strategy
  field :payoff, type: Float
  field :payoff_sd, type: Float
  
  validates :count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :role, presence: true
  validates :strategy, presence: true, uniqueness: { scope: :role }
  
  # def payoff_for(observation_id)
  #    players.where(observation_id: observation_id).avg(:payoff)
  #  end
  #  
  #  def payoff
  #    players.avg(:payoff)
  #  end
  #  
  #  def payoff_sd
  #    if players.count > 0
  #      Math.sqrt(players.sum{ |player| player.payoff**2.0 }/players.count-payoff**2.0)
  #    end
  #  end
end