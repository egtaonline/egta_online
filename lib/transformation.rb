module Transformation
  def transform_game(game, name = "")
    apply_transformation(copy_game(game, name))
  end

  def copy_game(game, name)
    game_copy = Game.create(:simulator_id => game.simulator_id, :name => game.name+name, :size => game.size, :parameters => game.parameters)
    game.parameters.each {|param| game_copy[param] = game[param]}
    game.strategies.each {|strategy| game_copy.strategies.create(:name => strategy.name)}
    game_copy.ensure_profiles
    game.profiles.each do |prof|
      profile = game_copy.profiles.detect{|copy_prof| copy_prof.strategy_array == prof.strategy_array}
      1.upto(prof.players.count) do |index|
        player = profile.players[index-1]
        prof.players[index-1].payoffs.each {|payoff| player.payoffs.create(:sample_id => payoff.sample_id, :payoff => payoff.payoff)}
      end
    end
    game.features.each do |feature|
      game_copy.features.create(:name => feature.name, :expected_value => feature.expected_value)
      copy_feature = game_copy.features.where(:name => feature.name).first
      feature.feature_samples.each {|sample| copy_feature.feature_samples.create(:feature_name => feature.name, :sample_id => sample.sample_id, :value => sample.value)}
    end
    return game_copy.save! ? game_copy : nil
  end

  def apply_transformation(game)
    game
  end
end