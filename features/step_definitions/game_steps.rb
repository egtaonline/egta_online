Given /^a game that matches those profiles exists$/ do
  @profiles = @simulator_instance.profiles
  @game = Fabricate(:game, simulator_instance: @simulator_instance, size: @profiles.first.size)
end

When /^I visit that game's page$/ do
  visit game_path(@game)
end

When /^add the strategies of those profiles to the game$/ do
  select "#{@profiles.first.symmetry_groups.first.role}", from: "role"
  fill_in "role_count", with: "#{@profiles.first.size}"
  click_button "Add Role"
  strategies = @profiles.collect{ |profile| profile.symmetry_groups.collect{ |group| group.strategy } }.flatten.uniq
  strategies.each do |strategy|
    select strategy, from: "#{@profiles.first.symmetry_groups.first.role}_strategy"
    click_button "Add Strategy"
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

Given /^3 games exist$/ do
  @objects = [Fabricate(:game, size: 5), Fabricate(:game, size: 4), Fabricate(:game, size: 6)]
end