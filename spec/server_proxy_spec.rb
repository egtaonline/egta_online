require 'spec_helper'

describe ServerProxy do
  before(:each) do
    @account = Account.make!
    @server_proxy = ServerProxy.new("d-108-249.eecs.umich.edu", "/home/bcassell/Test")
    @simulator = Simulator.make!
    @simulator.simulator = double('simulator')
    @simulator.simulator.stub(:path).and_return("/Users/bcassell/Ruby/egt_working_directory/epp_sim.zip")
    @simulator.save!
    @game = Game.make
    @game.simulator = @simulator
    @game.save!
    @server_proxy.start
    @ssh = Net::SSH.start(@server_proxy.host, @account.username, :password => @account.password)
    @server_proxy.setup_simulator(@simulator)
    @simulation = Simulation.make
    @game.profiles.create!
    ["AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:noRA:0.0", "AmbiguityAversePricing:noRA:0.0", "AmbiguityAversePricing:noRA:0.0", "BayesianPricing:RA:0.0", "BayesianPricing:RA:0.0"].each do |entry|
      @game.profiles.first.players.create!(:strategy => entry)
    end
    @game.profiles.first.simulations << @simulation
    @game.simulations << @simulation
    @simulation.save!
    @server_proxy.queue_pending_simulations
    @simulation = Simulation.first
    @simulation.update_attributes(:serial_id => 41352)
    @server_proxy.gather_samples(@simulation, ROOT_PATH+"/spec/support/")
    @game = Game.first
  end
  # describe "#setup_simulator" do
  #   it "should copy over the simulator to the server" do
  #     should_exist("#{@server_proxy.location}/#{@simulator.name}.zip")
  #   end
  #   it "should unzip the simulator" do
  #     should_exist("#{@server_proxy.location}/#{@simulator.name}-#{@simulator.version}/#{@simulator.name}")
  #   end
  #   it "should create the simulations folder" do
  #     should_exist("#{@server_proxy.location}/#{@simulator.name}-#{@simulator.version}/simulations")
  #   end
  # end
  # describe "#queue_pending_simulations" do
  #   it "should assign an account" do
  #     @simulation.account == @account
  #   end
  #   it "should cause the state transition to queue" do
  #     @simulation.state.should == 'queued'
  #   end
  #   it "should make the appropriate yaml file" do
  #     File.exists?(ROOT_PATH+"tmp/temp.yaml").should == true
  #   end
  #   it "should make a yaml file that can be loaded" do
  #     sim_parms = Array.new
  #     File.open(ROOT_PATH+"tmp/temp.yaml") { |yf| YAML::load_documents( yf ){|y| sim_parms.push y}}
  #     sim_parms.first.should == ["AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:noRA:0.0", "AmbiguityAversePricing:noRA:0.0", "AmbiguityAversePricing:noRA:0.0", "BayesianPricing:RA:0.0", "BayesianPricing:RA:0.0"]
  #     sim_parms.last["number_of_agents"].should == 120.0
  #   end
  #   it "should set up the folder hierarcy for the simulation" do
  #     should_exist("#{@server_proxy.location}/#{@simulator.name}-#{@simulator.version}/simulations/#{@simulation.serial_id}")
  #     should_exist("#{@server_proxy.location}/#{@simulator.name}-#{@simulator.version}/simulations/#{@simulation.serial_id}/simulation_spec.yaml")
  #     should_exist("#{@server_proxy.location}/#{@simulator.name}-#{@simulator.version}/simulations/#{@simulation.serial_id}/features")
  #   end
  # end
  describe "#gather_samples" do
    it "should add samples to the simulation" do
      @simulation.samples.count.should == 30
      @game.profiles.first.players.each {|player| puts player.payoffs.to_s}
      @game.profiles.first.players.first.payoffs.count.should == 30
    end
  end
  def should_exist(location)
    output = @ssh.exec!("if test -e "+location+"; then printf \"exists\"; else printf \"#{location}\"; fi")
    output.should == "exists"
  end
end