When /^I query that simulator for run time configurations$/ do
  @run_time_configurations = @simulator.run_time_configurations
end

Then /^I receive "([^"]*)"$/ do |arg1|
  @run_time_configurations.collect{|rtc| rtc.parameters}.should == eval(arg1)
end

Given /^that simulator has the strategy array "([^"]*)"$/ do |arg1|
  @simulator.strategy_array = eval(arg1)
  @simulator.save!
end

Given /^the second profile belongs to that run time configuration$/ do
  @run_time_configuration.profiles << @simulator.profiles[1]
  @simulator.profiles.last.save!
end