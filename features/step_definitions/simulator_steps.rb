Given /^a Simulator$/ do
  @simulator = Simulator.make
  Simulator.all.count.should == 1
  puts @simulator.parameters
end

Given /^the Game references the Simulator$/ do
  @simulator.games << @game
end

When /^I delete the Simulator$/ do
  @simulator.destroy
end

Then /^the Game is deleted$/ do
  Game.all.count.should == 0
end

Then /^the simulator is created$/ do
  @simulator = Simulator.first
  @simulator.should_not == nil
end
