Given /^that game has that profile$/ do
  @game.profiles << @profile
  @game.save!
end

Then /^the last game should have (\d+) profiles$/ do |arg1|
  Game.last.profiles.size.should == arg1.to_i
end


Given /^the last game has the strategy "([^"]*)"$/ do |arg1|
  game = Game.last
  game.add_strategy("All", arg1)
  game.save!
end

When /^I delete the strategy "([^"]*)" from that game$/ do |arg1|
  Game.last.delete_strategy_by_name("All", arg1)
end

Then /^that game should have a role named "([^"]*)" with the strategy array "([^"]*)"$/ do |arg1, arg2|
  r = Game.last.roles.where(name: arg1).first
  r.should_not == nil
  r.strategies.should == eval(arg2)
end
Then /^the first game should have (\d+) profiles$/ do |arg1|
  Game.first.profiles.size.should == arg1.to_i
end


Then /^that game should have the role "([^"]*)" with strategies "([^"]*)" and "([^"]*)"$/ do |arg1, arg2, arg3|
  Game.last.roles.first.name.should == arg1
  Game.last.roles.first.strategies.should == [arg2, arg3]
end

Then /^that game should have (\d+) profiles$/ do |arg1|
  Game.last.profiles.count.should == arg1.to_i
end

Given /^a game that matches those profiles$/ do
  @profiles = @simulator.profiles
  with_resque do
    @game = Fabricate(:game, simulator: @simulator, size: @profiles.first.size)
  end
end

When /^I visit that game's page$/ do
  visit game_path(@game)
end

When /^add the strategies of those profiles to the game$/ do
  with_resque do
    select "#{@profiles.first.symmetry_groups.first.role}", from: "role"
    fill_in "role_count", with: "#{@profiles.first.size}"
    click_button "Add Role"
    strategies = @profiles.collect{ |profile| profile.symmetry_groups.collect{ |group| group.strategy } }.flatten.uniq
    strategies.each do |strategy|
      select strategy, from: "#{@profiles.first.symmetry_groups.first.role}_strategy"
      click_button "Add Strategy"
    end
  end
end

When /^request a representation of the game$/ do
  click_link "Download JSON"
end

Then /^I should those profiles$/ do
  @profiles.each do |profile|
    profile.symmetry_groups do |sgroup|
      page.should have_content("\"role\":\"#{sgroup.role}\",\"strategy\":\"#{sgroup.strategy}\",\"count\":#{sgroup.count}")
    end
  end
end
