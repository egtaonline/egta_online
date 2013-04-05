class ObservationSymmetryGroup
  include Mongoid::Document

  embedded_in :observation

  field :p, as: :payoff, type: Float
  field :sd, as: :payoff_sd, type: Float
  field :n, as: :players, type: Array

  validates_presence_of :payoff, :payoff_sd

  def payoffs
    players.collect{ |player| player["p"] }.compact
  end
end