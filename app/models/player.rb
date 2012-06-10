class Player
  include Mongoid::Document
  
  embedded_in :symmetry_group
  
  field :payoff, type: Float
  field :observation_id, type: Integer
  field :private_values, type: Hash, default: {}
  
  validates :payoff, presence: true, numericality: true
  validates :observation_id, presence: true, numericality: { only_integer: true }
end