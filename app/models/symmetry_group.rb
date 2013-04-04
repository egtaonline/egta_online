class SymmetryGroup
  include Mongoid::Document

  embedded_in :profile

  field :role, type: String
  field :strategy, type: String
  field :count, type: Integer
  field :payoff, type: Float
  field :payoff_sd, type: Float

  def update_statistics(payoffs)
    self.payoff = ArrayMath.average(payoffs)
    self.payoff_sd = ArrayMath.std_dev(payoffs)
    self.save!
  end
end