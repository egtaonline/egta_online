Given /^the Game has a Profile$/ do
  @profile = Profile.make
  @game.profiles << @profile
end

Given /^the Profile has a Player$/ do
  @player = Player.make
  @profile.players << @player
end

Given /^the Player has a Payoff$/ do
  @payoff = Payoff.make
  @player.payoffs << @payoff
end

Given /^the Sample is referenced in the Payoff$/ do
  @payoff.update_attributes(:sample_id => @sample.id)
end

Then /^the Payoff is deleted$/ do
  @player.payoffs.count.should == 0
end
