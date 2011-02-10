module Transformation
  def transform_game(game, name = "")
    apply_transformation(copy_game(game, name))
  end

  def copy_game(game, name)
    g = Game.create(:simulator_id => game.simulator_id, :name => game.name+name)
    game.strategies.each {|x| g.strategies.create(x.name)}
    g.ensure_profiles
    game.profiles.each do |x|
      profile = g.profiles.detect{|z| z.strategy_array == x.strategy_array}
      x.players.each do |y|
        player = profile.players.where(:strategy => y.strategy).first
        y.payoffs.each {|z| player.payoffs.create(:sample_id => y.sample_id, :payoff => y.payoff)}
      end
    end
    game.features.each do |x|
      g.features.create(:name => x.name, :expected_value => x.expected_value)
      feature = g.where(:name => x.name).first
      x.feature_samples.each {|y| feature.feature_samples.create(:feature_name => x.name, :sample_id => y.sample_id, :value => y.value)}
    end
    g.save!
    return g
  end

  def apply_transformation(game)
    game
  end
end