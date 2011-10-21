class ProfileGatherer
  @queue = :profile_actions

  def self.perform(game_id)
    game = Game.find(game_id) rescue nil
    if game != nil
      game.update_attribute(:profile_ids, Profile.where(simulator_id: game.simulator_id, parameter_hash: game.parameter_hash, size: game.size).map(&:_id))
    end
  end
end