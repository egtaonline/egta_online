Given /^a profile and simulation to match the incoming data$/ do
  @profile = Fabricate(:profile, assignment: "All: 60 AmbiguityAversePricing:RA:false:ConstantQuantity_1:0.0")
  @simulation = Fabricate(:simulation, size: 4, profile: @profile, number: 516614)
end

When /^the data is parsed$/ do
  DataParser.perform(516614, 'features/support/516614')
end

Then /^the symmetry group of the profile will have (\d+) players$/ do |arg1|
  @profile.reload.symmetry_groups.first.players.count.should eql(arg1.to_i)
end

Then /^the profile will have matching correct features observations for each of the observations$/ do
  @profile.features_observations.first.features.should eql({"average_equity_premium"=>-1.2220978801483e-05, "average_dividend"=>1.9945048426565801, "average_signal"=>0.0100216213779099})
  @profile.features_observations[1].features.should eql({"average_equity_premium"=>0.299871911686234e-03, "average_dividend"=>2.05274775315298, "average_signal"=>-0.671875465181085e-02})
end