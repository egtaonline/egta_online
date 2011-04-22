require 'spec_helper'

describe ServerProxy do
  before(:each) do
    SimCount.make!
    @account = Account.make!
    @server_proxy = ServerProxy.new
    @simulator = Simulator.make!
    @simulator.simulator = double('simulator')
    @simulator.simulator.stub(:path).and_return("/Users/bcassell/Ruby/egt_working_directory/epp_sim.zip")
    @simulator.save!
    @game = Game.make!
    @game.simulator = @simulator
    @game.save!
    @server_proxy.start
    @ssh = Net::SSH.start(ServerProxy::HOST, @account.username, :password => @account.password)
    @server_proxy.setup_simulator(@simulator)
    @simulation = Simulation.make
    @game.profiles.create!
    @game.profiles.first.strategy_array = ["a", "b"]
    @game.profiles.first.simulations << @simulation
    @game.simulations << @simulation
    @simulation.save!
    @pbs_generator = PbsGenerator.make!
    @pbs_generator.simulations << @simulation
    @simulation.save!
    @server_proxy.queue_pending_simulations
    @simulation = Simulation.first
  end
  describe "#setup_simulator" do
    it "should copy over the simulator to the server" do
      should_exist("#{ServerProxy::LOCATION}/#{@simulator.name}.zip")
    end
    it "should unzip the simulator" do
      should_exist("#{ServerProxy::LOCATION}/#{@simulator.name}-#{@simulator.version}/#{@simulator.name}")
    end
    it "should create the simulations folder" do
      should_exist("#{ServerProxy::LOCATION}/#{@simulator.name}-#{@simulator.version}/simulations")
    end
  end
  describe "#queue_pending_simulations" do
    it "should assign an account" do
      @simulation.account == @account
    end
    it "should cause the state transition to queue" do
      @simulation.state.should == 'queued'
    end
    it "should make the appropriate yaml file" do
      File.exists?(ROOT_PATH+"tmp/temp.yaml").should == true
    end
    it "should make a yaml file that can be loaded" do
      sim_parms = Array.new
      File.open(ROOT_PATH+"tmp/temp.yaml") { |yf| YAML::load_documents( yf ){|y| sim_parms.push y}}
      sim_parms.first.should == ["a", "b"]
      sim_parms.last["number_of_agents"].should == 120.0
    end
    it "should set up the folder hierarcy for the simulation" do
      should_exist("#{ServerProxy::LOCATION}/#{@simulator.name}-#{@simulator.version}/simulations/0")
      should_exist("#{ServerProxy::LOCATION}/#{@simulator.name}-#{@simulator.version}/simulations/0/simulation_spec.yaml")
      should_exist("#{ServerProxy::LOCATION}/#{@simulator.name}-#{@simulator.version}/simulations/0/features")
    end
  end
  def should_exist(location)
    output = @ssh.exec!("if test -e "+location+"; then printf \"exists\"; else printf \"#{location}\"; fi")
    output.should == "exists"
  end
end