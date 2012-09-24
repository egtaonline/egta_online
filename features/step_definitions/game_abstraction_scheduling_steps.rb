When /^I add a role with valid counts$/ do
  visit "/#{@scheduler_class}s/#{@scheduler.id}"
  role = @simulator.roles.last
  select role.name, from: "role"
  fill_in "role_count", with: 4
  fill_in "reduced_count", with: 2
  click_button "Add Role"
end

When /^I add a role with invalid counts$/ do
  visit "/#{@scheduler_class}s/#{@scheduler.id}"
  role = @simulator.roles.last
  select role.name, from: "role"
  fill_in "role_count", with: 2
  fill_in "reduced_count", with: 4
  click_button "Add Role"
end

Then /^a reduced role should exist on that scheduler$/ do
  role = @scheduler.reload.roles.first
  role.count.should eql(4)
  role.reduced_count.should eql(2)
  role.name.should eql(@simulator.roles.first.name)
end

Then /^a reduced role should not exist on that scheduler$/ do
  @scheduler.reload.roles.count.should eql(0)
end
