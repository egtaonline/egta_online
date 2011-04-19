Given /^an existing server proxy$/ do
  @server_proxy = @account.server_proxy
end

Given /^a server proxy$/ do
  @server_proxy = ServerProxy.make!
end

Given /^the simulation is running and has serial_id 41352$/ do
  @simulation.update_attributes(:state => "running", :serial_id => 41352)
end

Given /^the profile references the simulation$/ do
  @profile.simulations << @simulation
  @simulation.save!
  @profile.strategy_array = ["AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:noRA:0.0", "AmbiguityAversePricing:noRA:0.0", "AmbiguityAversePricing:noRA:0.0", "BayesianPricing:RA:0.0", "BayesianPricing:RA:0.0"]
end

Given /^the data exists on the remote server$/ do
  @server_proxy.start
  @server_proxy.staging_session.scp.upload!(ROOT_PATH+"/features/support/41352", "epp_sim-Sim0001/simulations", :recursive => true)
end

When /^simulations are checked$/ do
  @server_proxy.check_simulations
end

When /^the server proxy is activated$/ do
  @server_proxy.start
end

Then /^a ssh session is created for the account$/ do
  @server_proxy.staging_session.closed?.should == false
  @server_proxy.sessions.servers_for(:scheduling).first.user.should == @account.username
  @server_proxy.sessions.servers_for(:scheduling).first.failed?.should == false
end

Then /^the folder is downloaded$/ do
  File.exists?(ROOT_PATH+"/db/41352")
end

Then /^the samples are added to the database$/ do
  Simulation.first.samples.count.should_not == 0
end

Then /^the payoffs are added to the profile$/ do
  Game.first.profiles.first.players.first.payoffs.count.should_not == 0
end

Then /^the features are created$/ do
  Game.first.features.count.should_not == 0
end

Then /^the feature samples are added to the features$/ do
  Game.first.features.first.feature_samples.count.should_not == 0
end
