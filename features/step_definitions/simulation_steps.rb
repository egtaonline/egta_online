Given /^the Game has a Simulation$/ do
  SimCount.make
  @simulation = Simulation.make
  @simulation.game = @game
end

Given /^the Simulation has a Sample$/ do
  @sample = Sample.make
  @simulation.samples << @sample
end

Given /^the Sample is referenced in the FeatureSample$/ do
  @feature_sample.update_attributes(:sample_id => @sample.id)
end

When /^I delete the Simulation$/ do
  @simulation.destroy
end