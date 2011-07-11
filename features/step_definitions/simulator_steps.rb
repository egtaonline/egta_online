Given /^that simulator has the strategy array "([^"]*)"$/ do |arg1|
  @simulator.strategy_array = eval(arg1)
  @simulator.save!
end