class ObservationSymmetryGroup
  include Mongoid::Document

  embedded_in :observation

  field :payoff, type: Float
  field :payoff_sd, type: Float
  field :players, type: Array

  validates_presence_of :payoff, :payoff_sd

  def payoffs
    players.collect{ |player| player["p"] }.compact
  end
end