require 'spec_helper'
require 'stringio'

describe SimulationChecker do
  before do
    ResqueSpec.reset!
  end
  
  describe "SimulationChecker.errors_from_folder" do
    it {SimulationChecker.errors_from_folder("spec/support/simulations/success").should == ""}
    it {SimulationChecker.errors_from_folder("spec/support/simulations/missing_payoffs").should == "Missing payoff data file."}
    it {SimulationChecker.errors_from_folder("spec/support/simulations/has_errors").should == "Oh noes, arbitrary errors!"}
  end
  describe "SimulationChecker.check_for_errors" do
    before :each do
      @simulator = Fabricate(:simulator)
      @profile = Fabricate(:profile, :simulator_id => @simulator.id, :parameter_hash => @simulator.parameter_hash)
      @simulation = Fabricate(:simulation, :profile_id => @profile.id, :number => 1)
    end
    it "should queue a DataParser job when the simulation folder looks correct" do
      SimulationChecker.check_for_errors(@simulation, "spec/support/simulations/success")
      DataParser.should have_queued(1)
    end
    it "should fail the job with the error when necessary" do
      SimulationChecker.check_for_errors(@simulation, "spec/support/simulations/has_errors")
      @simulation.state.should == "failed"
      @simulation.error_message.should == "Oh noes, arbitrary errors!"
    end
  end
end