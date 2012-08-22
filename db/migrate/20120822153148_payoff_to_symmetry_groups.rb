class PayoffToSymmetryGroups < Mongoid::Migration
  def self.up
    Profile.where(:sample_count.gt => 0).each do |profile|
      profile.symmetry_groups.where(:payoff.exists => false).each do |s|
        s.payoff = s.players.sum(:payoff).to_f/s.players.count
        payoffs_squared = s.players.collect{ |player| player.payoff**2.0 }.reduce(:+).to_f/s.players.count
        squared_payoffs = s.payoff**2.0
        if squared_payoffs < payoffs_squared
          s.payoff_sd = 0.0
        else
          s.payoff_sd = Math.sqrt(squared_payoffs-payoffs_squared)
        end
      end
      profile.save!
      puts Time.now
    end
  end

  def self.down
  end
end