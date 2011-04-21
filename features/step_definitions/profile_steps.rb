
Given /^the game has a profile$/ do
  @profile = Profile.make
  @game.profiles << @profile
  @profile.save!
end

Given /^the profile has a player$/ do
  @player = Player.make
  @profile.players << @player
  @player.save!
end

Given /^the player has a payoff$/ do
  @payoff = Payoff.make
  @player.payoffs << @payoff
  @payoff.save!
end

Given /^the sample is referenced in the payoff$/ do
  @payoff.update_attributes(:sample_id => @sample.id)
end

Then /^the payoff is deleted$/ do
  @player.payoffs.count.should == 0
end

Given /^a profile with a simulation with a single sample$/ do
  @game = Game.make
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
