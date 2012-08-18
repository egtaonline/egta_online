Given /^a profile and simulation to match the incoming data$/ do
  @profile = Fabricate(:profile, assignment: "All: 60 AmbiguityAversePricing:RA:false:ConstantQuantity_1:0.0")
  @simulation = Fabricate(:simulation, size: 4, profile: @profile)
end

When /^the data is parsed$/ do
  DataParser.perform(1, 'features/support/1')
end

Then /^the simulation will have the status complete$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the profile will have valid observations$/ do
  pending # express the regexp above with the code you wish you had
end