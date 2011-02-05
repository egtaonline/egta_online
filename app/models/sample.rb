# This model class represents samples obtained from simulations. It is associated with a Profile
# and usually the result of a Simulation.

class Sample
  include Mongoid::Document

  embedded_in :simulation
  embeds_many :payoffs, :dependent=>:destroy
  embeds_many :adjusted_payoffs, :dependent=>:destroy
  embeds_many :feature_samples, :dependent=>:destroy

  field :clean, :type => Boolean
end
