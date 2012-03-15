class DenormalizingSimulation < Mongoid::Migration
  def self.up
    Simulation.all.each do |s|
      s.update_attribute(:profile_name, s.profile.name)
      s.update_attribute(:account_username, s.account.username)
    end
  end

  def self.down
  end
end