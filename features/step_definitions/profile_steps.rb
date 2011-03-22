Given /^the game has a profile$/ do
  @profile = Profile.make
  @game.profiles << @profile
end

Given /^the profile has a player$/ do
  @player = Player.make
  @profile.players << @player
end

Given /^the player has a payoff$/ do
  @payoff = Payoff.make
  @player.payoffs << @payoff
end

Given /^the sample is referenced in the payoff$/ do
  @payoff.update_attributes(:sample_id => @sample.id)
end

Then /^the payoff is deleted$/ do
  @player.payoffs.count.should == 0
end
