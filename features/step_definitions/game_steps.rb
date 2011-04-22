Given /^a game$/ do
  @game = Game.make!
  @simulator = Simulator.make!
  @simulator.games << @game
  @game.save!
end

Given /^the game has a feature$/ do
  @feature = Feature.make
  @game.features << @feature
  @feature.save!
end

Given /^the feature has a feature sample$/ do
  @feature_sample = FeatureSample.make
  @feature.feature_samples << @feature_sample
  @feature_sample.save!
end

Then /^the feature sample is deleted$/ do
  @feature.feature_samples.count.should == 0
end

When /^I delete the game$/ do
  @game.destroy
end

Then /^the game is created$/ do
  @game = Game.first
  @game.should_not == nil
end
