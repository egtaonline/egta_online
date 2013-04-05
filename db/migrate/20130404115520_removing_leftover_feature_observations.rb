class RemovingLeftoverFeatureObservations < Mongoid::Migration
  def self.up
    Profile.where(:sample_count.gt => 0, observations: []).update_all(:sample_count => 0)
    Profile.where(:features_observations.exists => true, observations: []).unset(:features_observations)
    Profile.where(:features_observations.exists => true).each do |profile|
      profile["features_observations"].each do |fo|
        observation = profile.observations[fo["observation_id"]-1]
        observation.set(:features, observation.features.merge(fo["features"]))
      end
    end
    Profile.where(:features_observations.exists => true).unset(:features_observations)
    Profile.where(:features.exists => true).unset(:features)
  end

  def self.down
  end
end