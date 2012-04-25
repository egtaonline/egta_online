class CvCoefficientCalculator
  @queue = :profile_actions

  def self.perform(game_id)
    game = Game.find(game_id) rescue nil
    if game != nil
      game.cv_manager.calculate_coefficients
    end
  end
end