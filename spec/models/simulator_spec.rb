require 'spec_helper'

describe Simulator do
  describe "#location" do
    let(:simulator){Fabricate(:simulator)}
    it { simulator.location.should eql("#{Rails.root}/simulator_uploads/#{simulator.name}-#{simulator.version}") }
  end
    
  describe "setup and validation" do
    before(:each) do
      ResqueSpec.reset!
    end
    
    it "should replace any existing copy" do
      # Setup fake simulator
      system("mkdir -p #{Rails.root}/simulator_uploads/epp_sim-test/epp_sim/fakery")
      simulator = Fabricate(:simulator_realistic) 
      File.exists?("#{Rails.root}/simulator_uploads/epp_sim-test/epp_sim/fakery").should eql(false)
      File.exists?("#{Rails.root}/simulator_uploads/epp_sim-test/epp_sim/simulation_spec.yaml").should eql(true)
    end
    
    context "the simulator is valid" do
      let(:simulator){ Fabricate(:simulator_realistic) }
      it "should load the simulation_spec.yaml" do
        simulator.parameter_hash["number of agents"].should eql("120")
      end
    
      it "should schedule a job to setup the simulator on nyx" do
        SimulatorInitializer.should have_queued(simulator.id)
      end
    end
    
    it "should inform the user of a malformed simulation_spec.yaml and a missing script/batch file" do
      simulator = Fabricate.build(:simulator_realistic, :name => "fake2", :simulator_source => File.new("#{Rails.root}/spec/support/fake2.zip"))
      simulator.should have(2).errors_on(:simulator_source)
      simulator.errors[:simulator_source].should include("had a malformed simulation_spec.yaml file.")
      simulator.errors[:simulator_source].should include("did not find script/batch within #{simulator.location}/#{simulator.name}")
    end
  end
  
  describe "#remove_strategy" do
    context "simulator has a profile" do
      let!(:simulator){Fabricate(:simulator_with_strategies)}
      let!(:profile){Fabricate(:profile, :simulator => simulator, :name => "All: 2 #{simulator.roles.first.strategies.last}")}
      
      it "should destroy profiles that contain the strategy" do
        simulator.remove_strategy("All", simulator.roles.first.strategies.last)
        Profile.count.should eql(0)
      end
      
      it "should not destroy profiles that do not contain the strategy" do
        simulator.remove_strategy("All", simulator.roles.first.strategies.first)
        Profile.count.should eql(1)
      end
    end
  end
  
  describe "#remove_role" do
    context "simulator has a profile" do
      let!(:simulator){Fabricate(:simulator_with_strategies)}
      let!(:profile){Fabricate(:profile, :simulator => simulator, :name => "All: 2 #{simulator.roles.first.strategies.last}")}
      before :each do
        simulator.add_strategy("Alt", "AltStrat")
        profile2 = Fabricate(:profile, :simulator => simulator, :name => "Alt: 2 #{simulator.roles.last.strategies.last}")
      end
      it "should destroy only profiles that contain the role" do
        simulator.remove_role("All")
        Profile.count.should eql(1)
      end
    end
  end
end