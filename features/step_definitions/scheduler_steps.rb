When /^I add strategy "([^"]*)" to that symmetric game scheduler$/ do |arg1|
  @symmetric_game_scheduler.add_strategy_by_name(arg1)
end

Then /^I should have (\d+) simulations?$/ do |arg1|
  Simulation.all.each {|sim| puts sim.profile.proto_string }
  Simulation.count.should == arg1.to_i
end

Then /^I should have (\d+) simulations? scheduled$/ do |arg1|
  Simulation.all.each {|sim| puts sim.profile.proto_string }
  (Simulation.active.count+Simulation.pending.count).should == arg1.to_i
end

Then /^that simulation should have profile "([^"]*)"$/ do |arg1|
  @simulation = Simulation.first
  Profile.find(@simulation.profile_id).name.should == arg1
end

Then /^that simulation should have state "([^"]*)"$/ do |arg1|
  @simulation.state.should == arg1
end

Then /^all simulations should have state "([^"]*)"$/ do |arg1|
  Simulation.all.each { |sim| sim.state.should == "pending" }
end

Given /^that symmetric game scheduler is active$/ do
  @symmetric_game_scheduler.update_attribute(:active, true)
end

When /^I fail a simulation$/ do
  with_resque do
    @simulation = Simulation.first
    @simulation.failure!
  end
end

Then /^a new simulation should exist with identical settings to that simulation$/ do
  @new_simulation = Simulation.last
  @new_simulation.state.should == 'pending'
  @new_simulation.scheduler.should == @simulation.scheduler
  @new_simulation.profile.should == @simulation.profile
  @new_simulation.size.should == @simulation.size
end

Then /^a new simulation should not be created$/ do
  Simulation.count.should == 1
end

Given /^that symmetric profile belongs to the last scheduler$/ do
   scheduler = Scheduler.last
   scheduler.profiles << @symmetric_profile
   @symmetric_profile.save!
end

Given /^the last scheduler has that symmetric profile$/ do
  scheduler = Scheduler.last
  scheduler.profile_ids << @symmetric_profile.id
  scheduler.save!
end