# This model class has payoff values for players in a Game. This model has one-to-one relationships with
# Profile, Sample and Player.

class Payoff
  include Mongoid::Document
  embedded_in :player
  field :sample_id
  field :payoff, :type => Float
  validates_presence_of :sample_id
  validates_numericality_of :payoff

end



