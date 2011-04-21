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
    simulation.game.features.each do |feature|
      feature.feature_samples.where(:sample_id => id).destroy_all
    end
  end

  def kill_payoffs
    simulation.game.profiles.each do |profile|
      profile.players.each do |player|
        player.payoffs.where(:sample_id => id).destroy_all
      end
    end
  end

end
