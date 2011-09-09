Given /^those games have that symmetric profile and an analysis item$/ do
  Game.all.each {|game| game.profiles << @symmetric_profile; @symmetric_profile.save!}
end

Then /^the games' analysis items are outdated$/ do
  Game.all.each {|game| game.analysis_items.each {|ai| ai.outdated.should == true}}
end

Then /^the last game should have a profile with 1 sample$/ do
  Game.last.profiles.each {|p| puts p.sampled }
end

Given /^that game has that symmetric profile$/ do
  @game.profile_ids << @symmetric_profile.id
  @game.save!
end

Then /^the last game should have (\d+) profiles$/ do |arg1|
  Game.last.profile_ids.size.should == arg1.to_i
end


Given /^the last game has the strategy "([^"]*)"$/ do |arg1|
  game = Game.last
  game.strategy_array << arg1
  game.save!
end

When /^I delete the strategy "([^"]*)" from that game$/ do |arg1|
  @game.delete_strategy_by_name(arg1)
end