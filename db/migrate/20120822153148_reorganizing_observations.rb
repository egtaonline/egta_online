class ReorganizingObservations < Mongoid::Migration
  def self.up
    pool = Migrater.pool(size: 4)
    Profile.where(:sample_count.gt => 0, :observations.exists => false).batch_size(10).each do |profile|
      pool.migrate!(profile)
    end
  end

  def self.down
  end

  class Migrater
    include Celluloid

    def migrate(profile)
      t = Time.now
      o_array = Array.new(profile.sample_count){ { features: nil, symmetry_groups: [] } }
      profile['features_observations'].each { |f| o_array[f['observation_id']-1][:features] = f['features'] } if profile['features_observations']
      o_array = get_symmetry_groups(profile, o_array)
      o_array.each do |obv|
        profile.observations.create!(obv)
      end
      p "finish #{Time.now-t}"
    end

    def get_symmetry_groups(profile, o_array)
      profile.symmetry_groups.each do |symmetry_group|
        o_array.each { |entry| entry[:symmetry_groups] << { role: symmetry_group.role, strategy: symmetry_group.strategy, count: symmetry_group.count, players: [], payoff: 0.0, payoff_sd: 0.0 } }
        symmetry_group.players.each do |player|
          o_array[player['observation_id']-1][:symmetry_groups].last[:players] << { payoff: player.payoff, features: player.features }
        end
        o_array.each do |entry|
          sgroup = entry[:symmetry_groups].last
          pcount = sgroup[:players].size
          sgroup[:payoff] = sgroup[:players].collect{ |player| player[:payoff] }.reduce(:+).to_f/pcount
          payoffs_squared = sgroup[:players].collect{ |player| player[:payoff]**2.0 }.reduce(:+).to_f/pcount
          squared_payoffs = sgroup[:payoff]**2.0
          if squared_payoffs < payoffs_squared
            sgroup[:payoff_sd] = 0.0
          else
            sgroup[:payoff_sd] = Math.sqrt(squared_payoffs-payoffs_squared)
          end
        end
        symmetry_group.payoff = symmetry_group.players.avg(:payoff)
        payoffs_squared = symmetry_group.players.collect{ |player| player.payoff**2.0 }.reduce(:+).to_f/symmetry_group.players.count
        squared_payoffs = symmetry_group.payoff**2.0
        if squared_payoffs < payoffs_squared
          symmetry_group.payoff_sd = 0.0
        else
          symmetry_group.payoff_sd = Math.sqrt(squared_payoffs-payoffs_squared)
        end
        symmetry_group.save!
      end
      o_array
    end
  end
end