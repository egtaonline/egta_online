When /^I add strategy "([^"]*)" to that symmetric game scheduler$/ do |arg1|
  @symmetric_game_scheduler.add_strategy(arg1)
end

Then /^I should have (\d+) simulations?$/ do |arg1|
  Simulation.count.should == arg1.to_i
end

Then /^I should have (\d+) simulations? scheduled$/ do |arg1|
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

Given /^the last scheduler has that profile$/ do
  scheduler = Scheduler.last
  scheduler.profile_ids << @profile.id
  scheduler.save!
end

Given /^the last scheduler has the strategy "([^"]*)"$/ do |arg1|
  scheduler = Scheduler.last
  scheduler.add_strategy("All", arg1)
  scheduler.save!
end

When /^I delete the strategy "([^"]*)"$/ do |arg1|
  Scheduler.last.remove_strategy("All", arg1)
end

Then /^the last scheduler should have (\d+) profiles$/ do |arg1|
  Scheduler.last.profile_ids.size.should == 0
end

Then /^I should have (\d+) profile to be scheduled$/ do |arg1|
  ProfileScheduler.should have_scheduled(Profile.last.id).in(5 * 60)
end

Given /^a fleshed out simulator with a non\-empty (.*) exists$/ do |scheduler|
  step 'a fleshed out simulator exists'
  @scheduler_class = scheduler
  @scheduler = Fabricate("#{scheduler}_with_profiles".to_sym, simulator: @simulator)
  @profile_count = Profile.with_scheduler(@scheduler).count
  @profile_count.should_not eql(0)
end

When /^I edit a parameter of that scheduler$/ do
  visit "/#{@scheduler_class}s/#{@scheduler.id}/edit"
  fill_in "Parm1", with: 12345
  with_resque do
    click_button "Update #{@scheduler.class}"
  end
end

Then /^new profiles should be created$/ do
  Profile.count.should eql(@profile_count*2)
end

Then /^I should see the new parameter value$/ do
  page.should have_content("12345")
end

Given /^a fleshed out simulator with an empty (\w+) of size (\d+) exists$/ do |scheduler, size|
  step 'a fleshed out simulator exists'
  @scheduler_class = scheduler
  if scheduler == 'hierarchical_scheduler' || scheduler == 'hierarchical_deviation_scheduler'
    @scheduler = Fabricate("#{scheduler}".to_sym, simulator: @simulator, size: 4, agents_per_player: 2)
  else
    @scheduler = Fabricate("#{scheduler}".to_sym, simulator: @simulator, size: size.to_i)
  end
  @scheduler.configuration.should_not eql(nil)
end

When /^I add the role (.*) with size (.*) and the strategies (.*) to the scheduler$/ do |role, size, strategies|
  if role =~ /^\S+$/
    strategies.split(", ").each{ |strategy| @simulator.add_strategy(role, strategy) }
    visit "/#{@scheduler_class}s/#{@scheduler.id}"
    with_resque do
      select role, from: "role"
      fill_in "role_count", with: size
      click_button "Add Role"
      strategies.split(", ").each do |strategy|
        select strategy, from: "#{role}_strategy"
        click_button "Add Strategy"
      end
    end
  end
end

When /^I add the deviating strategy (\w+) to the role (\w+) on the scheduler$/ do |strategy, role|
  visit "/#{@scheduler_class}s/#{@scheduler.id}"
  with_resque do
    select strategy, from: "dev_#{role}_strategy"
    click_button "dev_#{role}"
  end
end

Then /^I should see the profiles (.*)$/ do |profiles|
  eval(profiles).each do |profile|
    page.should have_content(profile)
  end
  Profile.count.should eql(eval(profiles).size)
end

Given /^the simulator has a profile that matches the scheduler with the assignment (.*)$/ do |assignment|
  @simulator.profiles.create(assignment: assignment, configuration: @scheduler.configuration)
end

Given /^the simulator has a profile that does not match the scheduler with assignment (.*)$/ do |assignment|
  @simulator.profiles.create(assignment: assignment, configuration: { gibberish: "Fake" })
end

Given /^its profiles have been sampled$/ do
  Profile.with_scheduler(@scheduler).update_all(sample_count: 1)
end

When /^I visit that scheduler's page$/ do
  visit "/#{@scheduler_class}s/#{@scheduler.id}"
end

Then /^I should see a game that matches that scheduler$/ do
  current_path.should eql(game_path(Game.last))
  page.should have_content(@scheduler.name)
  page.should have_content(@scheduler.simulator_fullname)
  @scheduler.configuration.each { |key,value| page.should have_content(key); page.should have_content(value) }
end

Then /^I should see all the profiles of the scheduler that have been sampled$/ do
  @scheduler.profiles.each do |profile|
    profile.symmetry_groups do |sgroup|
      page.should have_content("\"role\":\"#{sgroup.role}\",\"strategy\":\"#{sgroup.strategy}\",\"count\":#{sgroup.count}")
    end
  end
end

When /^I configure a new (hierarchical_scheduler|hierarchical_deviation_scheduler) at creation$/ do |klass|
  visit "/#{klass}s/new"
  @config = {'Name' => 'Test1',
             'Full game size' => '2',
             'Agents per player' => '1',
             'Default samples' => '30',
             'Samples per simulation' => '15',
             'Process memory' => '1000',
             'Time per sample' => '40'}
  @config.each { |key, value| fill_in key, :with => value }
  click_button "Create #{klass.classify}"
end

When /^I edit the configuration of the (hierarchical_scheduler|hierarchical_deviation_scheduler)$/ do |klass|
  visit "/#{klass}s/#{@scheduler.id}/edit"
  @config = {'Name' => 'Test2',
             'Full game size' => '32',
             'Agents per player' => '16',
             'Default samples' => '20',
             'Samples per simulation' => '11',
             'Process memory' => '1040',
             'Time per sample' => '41'}
  @config.each { |key, value| fill_in key, :with => value }
  click_button "Update #{klass.classify}"
end

When /^I configure a new (game_scheduler|deviation_scheduler|generic_scheduler) at creation$/ do |klass|
  visit "/#{klass}s/new"
  @config = {'Name' => 'Test1',
             'Game size' => '2',
             'Default samples' => '30',
             'Samples per simulation' => '15',
             'Process memory' => '1000',
             'Time per sample' => '40'}
  @config.each { |key, value| fill_in key, :with => value }
  click_button "Create #{klass.classify}"
end

When /^I edit the configuration of the (game_scheduler|deviation_scheduler|generic_scheduler)$/ do |klass|
  visit "/#{klass}s/#{@scheduler.id}/edit"
  @config = {'Name' => 'Test5',
             'Game size' => '7',
             'Default samples' => '3',
             'Samples per simulation' => '1',
             'Process memory' => '3000',
             'Time per sample' => '20'}
  @config.each { |key, value| fill_in key, :with => value }
  click_button "Update #{klass.classify}"
end

Then /^I should see the configured values on that scheduler$/ do
  @config.each { |key,value| page.should have_content(key); page.should have_content(value) }
end

Given /^a (\w+)_scheduler exists$/ do |klass|
  @scheduler = Fabricate("#{klass}_scheduler".to_sym)
end

When /^I remove the strategy (\w+) on role (\w+) from the scheduler$/ do |strategy, role|
  visit "/#{@scheduler_class}s/#{@scheduler.id}"
  with_resque do
    click_link "remove-#{role}-#{strategy}"
  end
end

When /^I remove the deviation strategy (\w+) on role (\w+) from the scheduler$/ do |strategy, role|
  visit "/#{@scheduler_class}s/#{@scheduler.id}"
  with_resque do
    click_link "remove-dev-#{role}-#{strategy}"
  end
end

Then /^the scheduler should have (\d+) profiles$/ do |count|
  @scheduler.profiles.count.should eql(count.to_i)
end

When /^I remove the role (\w+) from the scheduler$/ do |role|
  with_resque do
    click_link "remove-#{role}"
  end
end