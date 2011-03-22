Given /^the game has a simulation$/ do
  SimCount.make
  @simulation = Simulation.make
  @simulation.game = @game
end

Given /^the simulation has a sample$/ do
  @sample = Sample.make
  @simulation.samples << @sample
end

Given /^the sample is referenced in the feature sample$/ do
  @feature_sample.update_attributes(:sample_id => @sample.id)
end

When /^I delete the simulation$/ do
  @simulation.destroy
end

Then /^the simulation is deleted$/ do
  Simulation.count.should == 0
end