Given /^that simulator has the strategy array "([^"]*)"$/ do |arg1|
  eval(arg1).each {|st| @simulator.add_strategy_by_name("All", st)}
  @simulator.save!
end

Then /^that simulator should have role_strategy_hash, "([^"]*)"$/ do |arg1|
  Simulator.last.role_strategy_hash.should == eval(arg1)
end

Given /^that simulator has the role strategy hash "([^"]*)"$/ do |arg1|
  Simulator.last.update_attribute(:role_strategy_hash, eval(arg1))
end