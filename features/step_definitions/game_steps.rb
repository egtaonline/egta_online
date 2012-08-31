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

Then /^the first game should have (\d+) profiles$/ do |arg1|
  Game.first.profiles.size.should == arg1.to_i
end

Given /^a game that matches those profiles exists$/ do
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

When /^I request a representation of the game$/ do
  click_link "Download JSON"
end

Then /^I should have those profiles$/ do
  @profiles.each do |profile|
    profile.symmetry_groups do |sgroup|
      page.should have_content("\"role\":\"#{sgroup.role}\",\"strategy\":\"#{sgroup.strategy}\",\"count\":#{sgroup.count}")
    end
  end
end

Given /^that simulator has a game that matches the scheduler$/ do
  @game = Fabricate(:game, simulator: @simulator, configuration: @scheduler.configuration, size: @scheduler.size)
end

Given /^that simulator has a game that does not match the scheduler$/ do
  @game = Fabricate(:game, simulator: @simulator, configuration: @scheduler.configuration.merge({ other_key: 'other_value' }), size: @scheduler.size)
end