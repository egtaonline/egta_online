# This model class represents samples obtained from simulations. It is associated with a Profile
# and usually the result of a Simulation.

class Sample
  include Mongoid::Document

  embedded_in :simulation
  field :clean, :type => Boolean
  field :file_name
  field :file_index, :type => Integer
  before_destroy :kill_payoffs

  def kill_payoffs
    simulation.game.features.each do |x|
      x.feature_samples.where(:sample_id => id).destroy_all
    end
    simulation.game.profiles.find(simulation.profile_id).players.each do |x|
      x.payoffs.where(:sample_id => id).destroy_all
    end
    simulation.game.features.each {|x| x.feature_samples.where(:sample_id => id).destroy_all}
  end
end
