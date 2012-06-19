class RenameProfileName < Mongoid::Migration
  def self.up
    Profile.all.each{ |g| g.rename(:name, :assignment) }
    Simulation.all.each{ |s| s.rename(:profile_name, :profile_assignment) }
  end

  def self.down
  end
end