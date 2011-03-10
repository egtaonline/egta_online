Given /^a GameScheduler$/ do
  @game_scheduler = GameScheduler.make
end

Given /^the GameScheduler references the Game$/ do
  @game_scheduler.game = @game
end

Then /^the GameScheduler is deleted$/ do
  GameScheduler.all.count.should == 0
end

Then /^the game scheduler is created$/ do
  @game_scheduler = GameScheduler.first
  @game_scheduler.should_not == nil
end

Given /^a PbsGenerator$/ do
  @pbs_generator = PbsGenerator.make
end
