require 'spec_helper'

describe ServerProxy do
  let!(:server_proxy) { Fabricate.build(:server_proxy) }
  let!(:simulator) { Fabricate(:simulator) }
  let!(:ssh) { Net::SSH.start(server_proxy.host, Account.first.username, :password => Account.first.password) }
  describe "#setup_simulator" do
    specify { should_exist("#{server_proxy.location}/#{simulator.name}.zip") }
    specify { should_exist("#{server_proxy.location}/#{simulator.fullname}/#{simulator.name}") }
    specify { should_exist("#{server_proxy.location}/#{simulator.fullname}/simulations") }
  end
  describe "#queue_pending_simulations" do
    context "single simulator, single simulation" do
      before do
        server_proxy.queue_pending_simulations
      end
      specify { Simulation.first.account.should == Account.first }
      specify { Simulation.first.state.should == 'queued'}
      specify { File.exists?(ROOT_PATH+"tmp/temp.yaml").should == true }
      it "should make a yaml file that can be loaded" do
        sim_parms = Array.new
        File.open(ROOT_PATH+"tmp/temp.yaml") { |yf| YAML::load_documents( yf ){|y| sim_parms.push y}}
        sim_parms.first.should == ["AmbiguityAversePricing:noRA:0.0", "BayesianPricing:noRA:0.0"]
        sim_parms.last["number of agents"].should == 120.0
      end
      specify { should_exist("#{server_proxy.location}/#{simulator.fullname}/simulations/#{Simulation.first.id}") }
      specify { should_exist("#{server_proxy.location}/#{simulator.fullname}/simulations/#{Simulation.first.id}/simulation_spec.yaml") }
      specify { should_exist("#{server_proxy.location}/#{simulator.fullname}/simulations/#{Simulation.first.id}/features") }
    end
    context "two simulators, single simulation" do
      let!(:simulator2) { Fabricate(:simulator) }
      before do
        simulator.games.first.simulations.delete_all
        simulator2.games.first.update_attribute("number of agents", 100)
        server_proxy.queue_pending_simulations
      end
      it "should make a yaml file that can be loaded" do
        sim_parms = Array.new
        File.open(ROOT_PATH+"tmp/temp.yaml") { |yf| YAML::load_documents( yf ){|y| sim_parms.push y}}
        sim_parms.first.should == ["AmbiguityAversePricing:noRA:0.0", "BayesianPricing:noRA:0.0"]
        sim_parms.last["number of agents"].should == 100.0
      end
    end
  end

  # describe "#gather_samples" do
  #   it "should add samples to the simulation" do
  #     @simulation.samples.count.should == 30
  #     @game.profiles.first.players.each {|player| puts player.payoffs.to_s}
  #     @game.profiles.first.players.first.payoffs.count.should == 30
  #   end
  # end
  def should_exist(location)
    output = ssh.exec!("if test -e "+location+"; then printf \"exists\"; else printf \"#{location}\"; fi")
    output.should == "exists"
  end
end