Given /^those games have that symmetric profile and an analysis item$/ do
  Game.all.each {|game| game.profiles << @symmetric_profile; @symmetric_profile.save!}
end

Then /^the games' analysis items are outdated$/ do
  Game.all.each {|game| game.analysis_items.each {|ai| ai.outdated.should == true}}
end

