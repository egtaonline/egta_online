class RenamingMaxSamples < Mongoid::Migration
  def self.up
    GameScheduler.all.each do |g|
      g.update_attribute(:default_samples, g["max_samples"])
    end
  end

  def self.down
  end
end