Given /^a game scheduler$/ do
  @game_scheduler = GameScheduler.make
end

Given /^the game scheduler references the game$/ do
  @game_scheduler.game = @game
end

Then /^the game scheduler is deleted$/ do
  GameScheduler.all.count.should == 0
end

Then /^the game scheduler is created$/ do
  @game_scheduler = GameScheduler.first
  @game_scheduler.should_not == nil
end

Given /^a pbs generator$/ do
  @pbs_generator = PbsGenerator.make
end
