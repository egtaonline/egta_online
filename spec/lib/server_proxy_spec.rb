require 'spec_helper'

describe ServerProxy do
  let!(:server_proxy) { ServerProxy.new }
  let!(:staging_session) { double("Net::SSH::Session")}
  let!(:simulator) { double("Simulator") }
  describe "#setup_simulator" do
    before do
      server_proxy.staging_session = staging_session
      simulator.stub(:fullname) { "MyName-1" }
      simulator.stub(:name) { "MyName" }
      simulator.stub_chain(:simulator_source, :path).and_return("")
      staging_session.stub_chain(:scp, :upload!).and_return("")
    end
    it "should set up the simulator on the remote server" do
      staging_session.should_receive(:exec!).with("rm -rf #{Yetting.deploy_path}/MyName-1*")
      staging_session.scp.should_receive(:upload!).with(simulator.simulator_source.path, Yetting.deploy_path)
      staging_session.should_receive(:exec!).with("cd #{Yetting.deploy_path}; unzip -u MyName.zip -d MyName-1; mkdir MyName-1/simulations")
      staging_session.should_receive(:exec!).with("cd #{Yetting.deploy_path}; chmod -R ug+rwx MyName-1")
      server_proxy.setup_simulator(simulator)
    end
  end
  #describe "#queue_pending_simulations" do
  #   context "single simulator, single simulation" do
  #     before do
  #       server_proxy.queue_pending_simulations
  #     end
  #     specify { Simulation.first.account.should == Account.first }
  #     specify { Simulation.first.state.should == 'queued'}
  #     specify { File.exists?(ROOT_PATH+"tmp/temp.yaml").should == true }
  #     it "should make a yaml file that can be loaded" do
  #       sim_parms = Array.new
  #       File.open(ROOT_PATH+"tmp/temp.yaml") { |yf| YAML::load_documents( yf ){|y| sim_parms.push y}}
  #       sim_parms.first.should == ["AmbiguityAversePricing:noRA:0.0", "BayesianPricing:noRA:0.0"]
  #       sim_parms.last["number of agents"].should == 120.0
  #     end
  #     specify { should_exist("#{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{Simulation.first.number}") }
  #     specify { should_exist("#{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{Simulation.first.number}/simulation_spec.yaml") }
  #     specify { should_exist("#{Yetting.deploy_path}/#{simulator.fullname}/simulations/#{Simulation.first.number}/features") }
  #   end
  #   context "two simulators, single simulation" do
  #     let!(:simulator2) { Fabricate(:simulator) }
  #     before do
  #       simulator.games.first.simulations.delete_all
  #       simulator2.games.first.update_attribute("number of agents", 100)
  #       server_proxy.queue_pending_simulations
  #     end
  #     it "should make a yaml file that can be loaded" do
  #       sim_parms = Array.new
  #       File.open(ROOT_PATH+"tmp/temp.yaml") { |yf| YAML::load_documents( yf ){|y| sim_parms.push y}}
  #       sim_parms.first.should == ["AmbiguityAversePricing:noRA:0.0", "BayesianPricing:noRA:0.0"]
  #       sim_parms.last["number of agents"].should == 100.0
  #     end
  #   end
  # end
  # describe "#gather_samples" do
  #   before do
  #     Simulation.first.update_attributes(:number => 41352)
  #     server_proxy.gather_samples(Simulation.first, "#{ROOT_PATH}/spec/support/")
  #   end
  #   it "should add samples to the simulation" do
  #     Simulation.first.samples.count.should == 6
  #     Simulator.first.games.first.profiles.first.players.first.payoffs.count.should == 6
  #   end
  # end
end