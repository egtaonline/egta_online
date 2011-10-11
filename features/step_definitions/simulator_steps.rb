Given /^that simulator has the strategy array "([^"]*)"$/ do |arg1|
  eval(arg1).each {|st| @simulator.add_strategy("All", st)}
  @simulator.save!
end

Then /^that simulator should have a role named "([^"]*)" with the strategy array "([^"]*)"$/ do |arg1, arg2|
  r = Simulator.last.roles.where(name: arg1).first
  r.should_not == nil
  r.strategy_array.should == eval(arg2)
end

Given /^that simulator has the role strategy hash "([^"]*)"$/ do |arg1|
  Simulator.last.update_attribute(:role_strategy_hash, eval(arg1))
end