class Player
  include Mongoid::Document

  embedded_in :symmetry_group

  field :payoff, type: Float
  field :features, type: Hash, default: {}

  validates :payoff, presence: true, numericality: true
end