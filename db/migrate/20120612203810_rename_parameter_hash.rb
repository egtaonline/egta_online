class RenameParameterHash < Mongoid::Migration
  def self.up
    Game.all.each{ |g| g.rename(:parameter_hash, :configuration) }
    Profile.all.each{ |g| g.rename(:parameter_hash, :configuration) }
    Scheduler.all.each{ |g| g.rename(:parameter_hash, :configuration) }
    Simulator.all.each{ |g| g.rename(:parameter_hash, :configuration) }
  end

  def self.down
    Game.all.each{ |g| g.rename(:configuration, :parameter_hash) }
    Profile.all.each{ |g| g.rename(:configuration, :parameter_hash) }
    Scheduler.all.each{ |g| g.rename(:configuration, :parameter_hash) }
    Simulator.all.each{ |g| g.rename(:configuration, :parameter_hash) }
  end
end