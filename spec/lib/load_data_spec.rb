require 'spec_helper'

describe DataLoader do
  before(:each) do
    @simulator = Simulator.make!
    @game = Game.make
    @game.simulator = @simulator
    @game.save!
    @simulation_pass = Simulation.make
    @game.profiles.create!
    ["AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:noRA:0.0", "AmbiguityAversePricing:noRA:0.0", "AmbiguityAversePricing:noRA:0.0", "BayesianPricing:RA:0.0", "BayesianPricing:RA:0.0"].each do |entry|
      @game.profiles.first.players.create!(:strategy => entry)
    end
    @simulation_pass.save!
    @simulation_pass.update_attributes(:serial_id => 41352)
    @game.profiles.first.simulations << @simulation_pass
    @game.simulations << @simulation_pass
    @simulation_pass.save!
    @simulation_pass.samples.create(:id => 1)
    @game.features.create!(:name => "average_payoff")
    @game.features.first.feature_samples.create!(:sample_id => 1, :value => -1)
    @game.profiles.first.players.first.payoffs.create!(:sample_id => 1, :payoff => -1)
    @simulation_fail = Simulation.make
    @game.profiles.create!
    ["AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:RA:0.0", "AmbiguityAversePricing:noRA:0.0", "AmbiguityAversePricing:noRA:0.0", "BayesianPricing:noRA:0.0", "BayesianPricing:noRA:0.0", "BayesianPricing:noRA:0.0"].each do |entry|
      @game.profiles.last.players.create!(:strategy => entry)
    end
    @simulation_fail.save!
    @simulation_fail.update_attributes(:serial_id => 1003)
    @game.profiles.last.simulations << @simulation_fail
    @game.simulations << @simulation_fail
    @simulation_fail.save!
    @data_l = DataLoader.new("#{ROOT_PATH}/spec/support")
    @data_l.load_folder(1003, "#{ROOT_PATH}/spec/support")
    @data_l.load_folder(41352, "#{ROOT_PATH}/spec/support")
    @simulation_fail = Simulation.where(:serial_id => 1003).first
    @simulation_pass = Simulation.where(:serial_id => 41352).first
    @game = Game.first
  end
  describe "#load_folder" do
    it "should set the simulation to failed if payoff_data does not exist" do
      @simulation_fail.state.should == 'failed'
    end
    it "should set the simulation to complete if payoff_data exists" do
      @simulation_pass.state.should == 'complete'
    end
    it "should add samples if it passes" do
      @simulation_pass.samples.count.should == 30
    end
    it "should add payoffs to the appropriate profile" do
      @game.profiles.find(@simulation_pass.profile_id).players.first.payoffs.count.should == 30
      @game.profiles.find(@simulation_pass.profile_id).players.where(:strategy => "AmbiguityAversePricing:RA:0.0").first.payoffs.first.payoff.should == 2937.92585227305
      @game.profiles.find(@simulation_pass.profile_id).players.where(:strategy => "AmbiguityAversePricing:RA:0.0").first.payoffs.first.sample_id.should == @simulation_pass.samples.first.id
      @game.profiles.find(@simulation_pass.profile_id).players.where(:strategy => "AmbiguityAversePricing:RA:0.0").first.payoffs.last.sample_id.should == @simulation_pass.samples.last.id
    end
    it "should add feature_samples with the appropriate id" do
      @simulation_pass.samples.each {|sample| @game.features.first.feature_samples.where(:sample_id => sample.id).count.should == 1}
    end
  end
  describe "#load_simulator" do
    it "should load for all simulations in games of the simulator" do
      @data_l.load_simulator(Simulator.first.name, Simulator.first.version, "#{ROOT_PATH}/spec/support")
      @simulation_fail = Simulation.where(:serial_id => 1003).first
      @simulation_pass = Simulation.where(:serial_id => 41352).first
      @game = Game.first
      @simulation_fail.state.should == 'failed'
      @simulation_pass.state.should == 'complete'
      @simulation_pass.samples.count.should == 30
      @game.profiles.find(@simulation_pass.profile_id).players.first.payoffs.count.should == 30
      @game.profiles.find(@simulation_pass.profile_id).players.where(:strategy => "AmbiguityAversePricing:RA:0.0").first.payoffs.first.payoff.should == 2937.92585227305
      @game.profiles.find(@simulation_pass.profile_id).players.where(:strategy => "AmbiguityAversePricing:RA:0.0").first.payoffs.first.sample_id.should == @simulation_pass.samples.first.id
      @game.profiles.find(@simulation_pass.profile_id).players.where(:strategy => "AmbiguityAversePricing:RA:0.0").first.payoffs.last.sample_id.should == @simulation_pass.samples.last.id
      @simulation_pass.samples.each {|sample| @game.features.first.feature_samples.where(:sample_id => sample.id).count.should == 1}
    end
  end
end