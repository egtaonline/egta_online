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
