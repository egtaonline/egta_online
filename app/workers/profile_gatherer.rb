class ProfileGatherer
  @queue = :profile_actions

  def self.perform(game_id)
    game = Game.find(game_id) rescue nil
    if game != nil
      puts "adding profiles to #{game.name}"
      game.profile_ids = Profile.where(simulator_id: game.simulator_id, parameter_hash: game.parameter_hash, size: game.size).map(&:_id)
      game.save!
    end
  end
end