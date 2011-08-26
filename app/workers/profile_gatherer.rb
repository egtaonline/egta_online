class ProfileGatherer
  @queue = :profile_actions

  def self.perform(game_id)
    game = Game.find(game_id) rescue nil
    if game != nil
      puts "adding profiles to #{game.name}"
      Profile.where(simulator_id: game.simulator_id, parameter_hash: game.parameter_hash, size: game.size).each do |profile|
        game.profiles << profile
        profile.save!
      end
    end
  end
end