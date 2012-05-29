Given /^that simulator has the strategy array "([^"]*)"$/ do |arg1|
  eval(arg1).each {|st| @simulator.add_strategy("All", st)}
  @simulator.save!
end
#
Then /^that simulator should have a role named "([^"]*)" with the strategy array "([^"]*)"$/ do |arg1, arg2|
  r = Simulator.last.roles.where(name: arg1).first
  r.should_not == nil
  r.strategies == eval(arg2)
end

Given /^that simulator has the role strategy hash "([^"]*)"$/ do |arg1|
  Simulator.last.update_attribute(:role_strategy_hash, eval(arg1))
end

Given /^that simulator has (\d+) role$/ do |arg1|
  arg1.to_i.times {@simulator.roles << Fabricate.build(:role)}
  @simulator.save!
end

Given /^that simulator has (\d+) game scheduler$/ do |arg1|
  arg1.to_i.times {Fabricate(:game_scheduler, :simulator => @simulator)}
  @simulator.save!
end

Given /^that role has (\d+) strategies$/ do |arg1|
  role = @simulator.roles.last
  arg1.to_i.times {|i| role.strategies << "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[i]}
  role.save!
end

Given /^that role has the strategies "([^"]*)" and "([^"]*)"$/ do |arg1, arg2|
  role = @simulator.roles.last
  role.strategies << arg1
  role.strategies << arg2
  role.save!
end

Given /^the strategy "([^"]*)"$/ do |arg1|
  @strategy = arg1
end

When /^I upload a new simulator$/ do
  @simulator_name ||= "my_simulator"
  @simulator_version ||= "alpha"
  visit "/simulators/new"
  fill_in "Name", :with => @simulator_name
  fill_in "Version", :with => @simulator_version
  attach_file "Zipped Source", "#{Rails.root}/features/support/epp_sim.zip"
  click_on "Upload Simulator"
end

Then /^I should see the simulator's name and default configuration$/ do
  page.should have_content @simulator_name
  page.should have_content @simulator_version
  page.should have_content "Number of agents"
  page.should have_content "120"
  page.should_not have_content "error"
end

Then /^the simulator should be eventually be set up on the server$/ do
  SimulatorInitializer.should have_queued(Simulator.last.id)
end