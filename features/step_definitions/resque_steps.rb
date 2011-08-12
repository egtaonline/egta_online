Then /^I should have (\d+) account associated with the server proxy$/ do |arg1|
  NYX_PROXY.sessions.servers.flatten.size.should == arg1.to_i
end

Given /^resque is being used and I add 1 account$/ do
  with_resque do
    Given "1 account"
  end
end

