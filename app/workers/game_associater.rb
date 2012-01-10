class GameAssociater
  @queue = :profile_actions

  def self.perform(profile_id)
    profile = Profile.find(profile_id) rescue nil
    if profile != nil
      Game.where(simulator_id: profile.simulator_id, parameter_hash: profile.parameter_hash, size: profile.size).each do |game|
        game.profile_ids << profile.id if game.profile_ids.include?(profile.id) == false
        game.save!
      end
    end
  end
end