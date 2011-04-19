Given /^a simulator$/ do
  @simulator = Simulator.make!
  Simulator.all.count.should == 1
  puts @simulator.parameters
end

Given /^the game references the simulator$/ do
  @simulator.games << @game
end

When /^I delete the simulator$/ do
  @simulator.destroy
end

Then /^the game is deleted$/ do
  Game.all.count.should == 0
end

Then /^the simulator is created$/ do
  @simulator = Simulator.first
  @simulator.should_not == nil
end
