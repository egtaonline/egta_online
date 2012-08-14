class MovingToObservations < Mongoid::Migration
  def self.up
    Profile.where(:sample_count.gt => 0, :observations => nil).limit(1).each do |profile|
      observation_ids = profile['symmetry_groups'].collect { |s| s['players'].collect{ |p| p['observation_id'] } }.flatten.uniq
      observation_ids.each do |oid|
        symmetry_groups = profile['symmetry_groups'].collect do |s|
          { role: s['role'], strategy: s['strategy'], count: s['count'], players: s['players'].select{ |p| p['observation_id'] == oid }.collect{ |p| { payoff: p['payoff'], features: p['features'] } } }
        end
        features = profile['features_observations'].select{ |f| f['observation_id'] == oid }.first.features if profile['features_observations']
        profile.observations.create!(features: features, symmetry_groups: symmetry_groups)
      end
      profile.inspect
    end
  end

  def self.down
  end
end