class ReorganizingPayoffData < Mongoid::Migration
  class ::Observation
    embeds_many :symmetry_groups, as: :role_strategy_partitionable
  end

  class ::SymmetryGroup
    embedded_in :role_strategy_partitionable, polymorphic: true
    embeds_many :players
    field :payoff, type: Float
    field :payoff_sd, type: Float
  end

  class ::Player
    include Mongoid::Document
    embedded_in :symmetry_group
    field :payoff, type: Float
    field :features, type: Hash
  end

  class ProfileMigrator
    include Celluloid

    def migrate(profile)
      flag = true
      profile.observations.each do |observation|
        observation.set(:f, observation.features)
        if observation["f"] == observation.features
          observation.unset(:features)
        else
          puts "failed on features"
          flag = false
        end
        sg = []
        profile.symmetry_groups.each do |symmetry_group|
          if flag
            osg = observation.symmetry_groups.where(role: symmetry_group.role, strategy: symmetry_group.strategy).first
            if osg == nil
              puts symmetry_group.role
              puts symmetry_group.strategy
              puts observation.symmetry_groups
            end
            o_hash = { "n" => [], "p" => osg.payoff, "sd" => osg.payoff_sd }
            osg.players.each do |player|
              player_hash = {"p" => player.payoff }
              player.features.each do |k,v|
                player_hash[profile.simulator_instance.get_storage_key(k)] = v
              end
              o_hash["n"] << player_hash
            end
            observation.set(:sg, o_hash)
            if observation["sg"]["n"].collect{ |player| player["p"] } != osg.players.collect{ |player| player.payoff }
              flag = false
              puts "failed on payoff comparison"
            end
          end
        end
        observation.unset(:symmetry_groups) if flag
      end
      if flag == false
        puts "migrating failed for #{profile.id}"
      else
        puts "success"
      end
    end
  end

  def self.up
    pool = ProfileMigrator.pool(size: 10)
    Profile.all.each{ |profile| pool.migrate(profile) }
  end

  def self.down
  end
end