Given /^a GameScheduler$/ do
  @game_scheduler = GameScheduler.make
end

Given /^the GameScheduler references the Game$/ do
  @game_scheduler.game = @game
end

Then /^the GameScheduler is deleted$/ do
  GameScheduler.all.count.should == 0
end
