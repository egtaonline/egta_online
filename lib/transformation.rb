module Transformation
  def transform_game(game, name = "")
    apply_transformation(copy_game(game, name))
  end

  def copy_game(game, name)
    g = Game.create(:simulator_id => game.simulator_id, :name => game.name+name, :size => game.size, :parameters => game.parameters)
    game.parameters.each {|x| g[x] = game[x]}
    game.strategies.each {|x| g.strategies.create(:name => x.name)}
    g.ensure_profiles
    game.profiles.each do |x|
      profile = g.profiles.detect{|z| z.strategy_array == x.strategy_array}
      1.upto(x.players.count) do |y|
        player = profile.players[y-1]
        x.players[y-1].payoffs.each {|z| player.payoffs.create(:sample_id => z.sample_id, :payoff => z.payoff)}
      end
    end
    game.features.each do |x|
      g.features.create(:name => x.name, :expected_value => x.expected_value)
      feature = g.features.where(:name => x.name).first
      x.feature_samples.each {|y| feature.feature_samples.create(:feature_name => x.name, :sample_id => y.sample_id, :value => y.value)}
    end
    if g.save!
      return g
    else
      nil
    end
  end

  def apply_transformation(g)
    g
  end
end