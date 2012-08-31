Given /^a profile and simulation to match the incoming data$/ do
  @profile = Fabricate(:profile, assignment: "All: 60 AmbiguityAversePricing:RA:false:ConstantQuantity_1:0.0")
  @simulation = Fabricate(:simulation, size: 4, profile: @profile)
end

When /^the data is parsed$/ do
  DataParser.perform(1, 'features/support/1')
end

Then /^the simulation will be in the (.*) state$/ do |state|
  @simulation.reload.state.should eql(state)
end

Then /^the profile will have valid observations$/ do
  jsons = [0, 1, 2, 3].collect {|i| Oj.load_file("#{Rails.root}/features/support/1/observation#{i}.json", mode: :compat) }
  @profile = Profile.find(@profile.id)
  @profile.symmetry_groups.first.payoff.round(4).should eql((jsons.collect{ |json| json['players'].map{ |p| p['payoff'] }.reduce(:+) }.reduce(:+)/240).round(4))
  @profile.symmetry_groups.first.payoff_sd.round(4).should eql(Math.sqrt(jsons.collect{ |json| json['players'].map{ |p| p['payoff']**2.0 }.reduce(:+) }.reduce(:+)/240 - (jsons.collect{ |json| json['players'].map{ |p| p['payoff'] }.reduce(:+) }.reduce(:+)/240)**2.0).round(4))
  @profile.features.each do |key, value|
    value.round(4).should eql((jsons.collect{ |j| j['features'][key] }.reduce(:+)/4).round(4))
  end
  @profile.observations.count.should eql(4)
  @profile.sample_count.should eql(4)
  count = 0
  @profile.observations.each do |observation|
    observation.symmetry_groups.first.role.should eql('All')
    observation.symmetry_groups.first.strategy.should eql('AmbiguityAversePricing:RA:false:ConstantQuantity_1:0.0')
    observation.symmetry_groups.first.count.should eql(60)
    observation.symmetry_groups.first.players.count.should eql(60)    
    payoff = jsons[count]['players'].map{ |p| p['payoff'] }.reduce(:+)/60.0
    observation.symmetry_groups.first.payoff.round(4).should eql(payoff.round(4))
    observation.symmetry_groups.first.payoff_sd.round(4).should eql(Math.sqrt(jsons[count]['players'].map{ |p| p['payoff']**2.0 }.reduce(:+)/60.0-payoff**2.0).round(4))
    count += 1
  end
end