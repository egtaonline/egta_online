Then /^that simulator should have a role named "([^"]*)" with the strategy array "([^"]*)"$/ do |arg1, arg2|
  r = Simulator.last.roles.where(name: arg1).first
  r.should_not == nil
  r.strategies == eval(arg2)
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

Given /^a fleshed out simulator exists$/ do
  @simulator = Fabricate(:simulator_with_strategies)
end

Given /^two simulators with different default configuration exist$/ do
  @simulator = Fabricate(:simulator_with_strategies, configuration: { 'Parm1' => '2', 'Parm2' => '3' })
  @simulator2 = Fabricate(:simulator_with_strategies, configuration: { 'Parm3' => '4', 'Parm4' => '2' })
end

Then /^I should see the default configuration of the first simulator$/ do
  @simulator.configuration.each { |key,value| find_field(key).value.should eql(value) }
end

When /^I select the first simulator$/ do
  select @simulator.fullname, from: 'Simulator'
end

When /^I select the second simulator$/ do
  select @simulator2.fullname, from: 'Simulator'
end

Then /^I should see the default configuration of the last simulator$/ do
  @simulator2.configuration.each { |key,value| find_field(key).value.should eql(value) }
end

Given /^a fleshed out simulator with sampled profiles exists$/ do
  @simulator = Fabricate(:simulator_with_profiles)
  @simulator.profiles.each{|p| p.update_attribute(:sample_count, 1) }
end

Given /^a simulator exists$/ do
  @simulator = Fabricate(:simulator)
end

Given /^3 simulators exist$/ do
  @objects = [Fabricate(:simulator, description: 'Second'), Fabricate(:simulator, description: 'First'), Fabricate(:simulator, description: 'Third')]
end

Then /^I should see the simulators in the default order$/ do
step 'I should see the following table rows:', table("| #{@objects.collect{ |o| o.name }.join(" |\n| ")} |")
end