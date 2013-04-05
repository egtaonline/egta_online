class UnsetConfigurationOnProfiles < Mongoid::Migration
  def self.up
    Profile.all.unset(:configuration)
    Profile.all.unset(:simulator_id)
    Simulator.all.unset(:profile_ids)
  end

  def self.down
  end
end