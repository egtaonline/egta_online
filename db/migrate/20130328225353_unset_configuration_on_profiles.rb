class UnsetConfigurationOnProfiles < Mongoid::Migration
  def self.up
    Profile.all.unset(:configuration)
  end

  def self.down
  end
end