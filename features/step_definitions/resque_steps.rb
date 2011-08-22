Then /^I should have (\d+) account associated with the server proxy$/ do |arg1|
  sessions.servers.flatten.size.should == arg1.to_i
end

Given /^a fake server proxy$/ do
  staging_session = double("staging_session")
  sessions = double("sessions")
  staging_session.stub("exec!")
  staging_session.stub_chain("scp.upload!")
  serv = stub("servers_for")
  serv2 = stub("server")
  sess = stub("sess")
  channel = stub("channel")
  channel.stub("wait")
  channel.stub("[]")
  sess.stub("exec").and_return(channel)
  serv2.stub("session").and_return(sess)
  serv.stub_chain("flatten.detect").and_return(serv2)
  sessions.stub("servers_for").and_return(serv)
end


Given /^resque is being used and I add 1 account$/ do
  with_resque do
    Given "1 account"
  end
end

Then /^I should have a "([^"]*)" job queued with "([^"]*)"$/ do |arg1, arg2|
  arg1.constantize.should have_queued(*eval(arg2))
end

When /^I process the next job for "([^"]*)"$/ do |arg1|
  ResqueSpec.perform_next(arg1)
end
Then /^"([^"]*)" should have "([^"]*)" jobs? queued$/ do |arg1, arg2|
  arg1.constantize.should have_queue_size_of(arg2.to_i)
end
