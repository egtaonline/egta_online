# This model class represents samples obtained from simulations. It is associated with a Profile
# and usually the result of a Simulation.

class Sample
  include Mongoid::Document
  embedded_in :simulation

  field :clean, :type => Boolean
  field :file_name
  field :file_index, :type => Integer

  before_destroy :kill_feature_samples, :kill_payoffs

  def kill_feature_samples
    simulation.game.remove_feature_samples(id)
  end

  def kill_payoffs
    simulation.game.remove_payoffs(simulation.profile_id, id)
  end

end
