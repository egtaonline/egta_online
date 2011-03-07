Given /^a profile with a simulation with a single sample$/ do
  @simulator = Simulator.make
  @simulator.games << Game.make
  @game = @simulator.games.first
  @game.profiles << make_profile_with_descendents
  @sample_id = @game.profiles.first.simulations.first.samples.first.id
end

When /^I delete the simulation$/ do
  @game.profiles.first.simulations.first.destroy
end

When /^I delete the sample$/ do
  @game.profiles.first.simulations.first.samples.first.destroy
end

Then /^no players in the profile will have payoffs that reference that sample$/ do
  @game.profiles.first.players.each do |player|
    player.payoffs.where(:sample_id => @sample_id).count.should == 0
  end
end
