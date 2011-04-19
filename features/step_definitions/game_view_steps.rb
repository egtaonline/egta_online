Given /^a user$/ do
  User.make!
end

Given /^I am logged in as that user$/ do
  visit "/users/sign_in"
  fill_in "Email", :with => 'test@test.com'
  fill_in "Password", :with => 'stuff1'
  check "Remember me"
  click_button "Sign in"
end

Given /^(\d+) simulators$/ do |arg1|
  1.upto(arg1.to_i) { Simulator.make! }
end

Given /^the first simulator has (\d+) game$/ do |arg1|
  1.upto(arg1.to_i) {Simulator.first.games << Game.make!}
end

Given /^the second simulator has (\d+) games$/ do |arg1|
  1.upto(arg1.to_i) {Simulator.last.games << Game.make!}
end

When /^I select the second simulator from the select menu$/ do
  select "epp_sim-Sim0002"
end

Then /^I should see the second simulator's games$/ do
  page.should have_content("Game0003")
end

