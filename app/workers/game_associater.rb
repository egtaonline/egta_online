class GameAssociater
  @queue = :profile_actions

  def self.perform(profile_id)
    profile = Profile.find(profile_id) rescue nil
    if profile != nil
      File.open("test", 'a') {|f| f.write("associating") }
      Game.where(simulator_id: profile.simulator_id, parameter_hash: profile.parameter_hash).each do |game|
        game.profiles << profile
        profile.save!
      end
    end
  end
end