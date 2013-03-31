Given /^a fleshed out simulator with a non\-empty (.*) exists$/ do |scheduler|
  step 'a fleshed out simulator exists'
  @scheduler_class = scheduler
  @simulator_instance = Fabricate(:simulator_instance, simulator: @simulator)
  @scheduler = Fabricate("#{scheduler}_with_profiles".to_sym, simulator_instance: @simulator_instance)
  @profile_count = Profile.with_scheduler(@scheduler).count
end

Given /^a (.*) with sampled profiles$/ do |scheduler|
  @scheduler_class = scheduler
  @scheduler = Fabricate("#{scheduler}_with_sampled_profiles".to_sym)
end

Given /^that scheduler has target and deviating strategies$/ do
  @scheduler.add_role("All", @scheduler.size, @scheduler.size)
  @scheduler.add_strategy("All", "A123")
  @scheduler.add_deviating_strategy("All", "B456")
end

Then /^I should see a game with all the specified strategies$/ do
  current_path.should eql(game_path(Game.last))
  page.should have_content('A123')
  page.should have_content('B456')
end


When /^I edit a parameter of that scheduler$/ do
  visit "/#{@scheduler_class}s/#{@scheduler.id}/edit"
  fill_in "Parm1", with: 12345
  click_button "Update #{@scheduler.class}"
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
  @simulator_instance = Fabricate(:simulator_instance, simulator: @simulator)
  @scheduler = Fabricate("#{scheduler}".to_sym, simulator_instance: @simulator_instance, size: size.to_i)
end

Given /^a fleshed out simulator with an empty (\w+)$/ do |scheduler|
  step 'a fleshed out simulator exists'
  @scheduler_class = scheduler
  @simulator_instance = Fabricate(:simulator_instance, simulator: @simulator)
  @scheduler = Fabricate("#{scheduler}".to_sym, simulator_instance: @simulator_instance, size: 4)
end

When /^I add the role (.*) with size (.*) and the strategies (.*) to the scheduler$/ do |role, size, strategies|
  if role =~ /^\S+$/
    strategies.split(", ").each{ |strategy| @simulator.add_strategy(role, strategy) }
    visit "/#{@scheduler_class}s/#{@scheduler.id}"
    select role, from: "role"
    fill_in "role_count", with: size
    fill_in "reduced_count", with: size if [HierarchicalScheduler, HierarchicalDeviationScheduler, DprGameScheduler, DprDeviationScheduler].include?(@scheduler.class)
    click_button "Add Role"
    strategies.split(", ").each do |strategy|
      select strategy, from: "#{role}_strategy"
      click_button "Add Strategy"
    end
  end
end

When /^I add the role All with the strategy A to the scheduler$/ do
  @simulator.add_strategy("All", "A")
  visit "/#{@scheduler_class}s/#{@scheduler.id}"
  select "All", from: "role"
  fill_in "role_count", with: @scheduler.size
  click_button "Add Role"
  select "A", from: "All_strategy"
  click_button "Add Strategy"
end

When /^I add the deviating strategy (\w+) to the role (\w+) on the scheduler$/ do |strategy, role|
  visit "/#{@scheduler_class}s/#{@scheduler.id}"
  select strategy, from: "dev_#{role}_strategy"
  click_button "dev_#{role}"
end

Then /^I should see these profiles: (.*)$/ do |profiles|
  eval(profiles).each do |profile|
    page.should have_content(profile)
  end
  Profile.all.collect { |p| puts p.assignment }
  Profile.count.should eql(eval(profiles).size)
end

Given /^the scheduler's simulator instance has a profile with the assignment (.*)$/ do |assignment|
  @simulator_instance.profiles.find_or_create_by(assignment: assignment)
  @simulator_instance.reload
end

Given /^a different simulator instance has a profile with the assignment (.*)$/ do |assignment|
  @simulator_instance2 = Fabricate(:simulator_instance, simulator: @simulator, configuration: {"other" => "gibberish"})
  @simulator_instance2.profiles.find_or_create_by(assignment: assignment)
  @simulator_instance2.reload
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
  @scheduler.simulator_instance.configuration.each { |key,value| page.should have_content(key); page.should have_content(value) }
end

Then /^I should see all the profiles of the scheduler that have been sampled$/ do
  @scheduler.profiles.each do |profile|
    profile.symmetry_groups do |sgroup|
      page.should have_content("\"role\":\"#{sgroup.role}\",\"strategy\":\"#{sgroup.strategy}\",\"count\":#{sgroup.count}")
    end
  end
end

When /^I configure a new (\w+) at creation$/ do |klass|
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

When /^I edit the configuration of the (\w+)$/ do |klass|
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
  click_link "remove-#{role}-#{strategy}"
end

When /^I remove the deviation strategy (\w+) on role (\w+) from the scheduler$/ do |strategy, role|
  visit "/#{@scheduler_class}s/#{@scheduler.id}"
  click_link "remove-dev-#{role}-#{strategy}"
end

Then /^the scheduler should have (\d+) profiles$/ do |count|
  @scheduler.profiles.count.should eql(count.to_i)
end

When /^I remove the role (\w+) from the scheduler$/ do |role|
  click_link "remove-#{role}"
end

Given /^3 schedulers exist$/ do
  simulators = [Fabricate(:simulator, name: 'real', version: 'realest'), Fabricate(:simulator, name: 'fake', version: 'less'), Fabricate(:simulator, name: 'fake', version: 'more')]
  @objects = simulators.collect{ |simulator| Fabricate(:game_scheduler, simulator_instance: Fabricate(:simulator_instance, simulator: simulator)) }
end

When /^I visit the (\w+) index page$/ do |arg|
  visit "/#{arg}"
end

Then /^I should see the (schedulers|games) in the default order$/ do |arg|
  step 'I should see the following table rows:', table("| #{@objects.collect{ |o| o.simulator_fullname }.join(" |\n| ")} |")
end

Given /^that generic_scheduler has 3 profiles$/ do
  @objects = [Fabricate(:profile, simulator_instance: @scheduler.simulator_instance, assignment: "All: 1 A, 1 B", sample_count: 10, scheduler_ids: [@scheduler.id]),
    Fabricate(:profile, simulator_instance: @scheduler.simulator_instance, assignment: "All: 2 A", sample_count: 5, scheduler_ids: [@scheduler.id]),
    Fabricate(:profile, simulator_instance: @scheduler.simulator_instance, assignment: "All: 2 B", sample_count: 20, scheduler_ids: [@scheduler.id])
    ]
end

When /^I visit that generic_scheduler's page$/ do
  visit "/generic_schedulers/#{@scheduler.id}"
end

Then /^I should see the profiles in the default order$/ do
  step 'I should see the following table rows:', table("| #{@objects.collect{ |o| o.assignment }.join(" |\n| ")} |")
end