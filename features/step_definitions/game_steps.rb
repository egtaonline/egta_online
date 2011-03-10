Given /^a Game$/ do
  @game = Game.make
  @simulator = Simulator.make
  @simulator.games << @game
end

Given /^the Game has a Feature$/ do
  @feature = Feature.make
  @game.features << @feature
end

Given /^the Feature has a FeatureSample$/ do
  @feature_sample = FeatureSample.make
  @feature.feature_samples << @feature_sample
end

Then /^the FeatureSample is deleted$/ do
  @feature.feature_samples.count.should == 0
end

When /^I delete the Game$/ do
  @game.destroy
end

Then /^the game is created$/ do
  @game = Game.first
  @game.should_not == nil
end
