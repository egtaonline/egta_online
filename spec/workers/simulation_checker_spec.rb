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
      @profile = Fabricate(:profile)
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
  describe "SimulationChecker.parse_nyx_output" do
    let!(:output){"6920852.nyx.engi     bcassell flux     mas-epp_sim             26276   --   --    --  24:00 Q -- 
6920853.nyx.engi     bcassell flux     mas-epp_sim             18145   --   --    --  24:00 R 02:36
6921265.nyx.engi     bcassell   cac      mas-epp_sim               15244   --   --    --  120:0 C 00:03"}
    it "should parse the output in a useful way" do
      parse_output = SimulationChecker.parse_nyx_output(output)
      parse_output["6920852"].should == "Q"
      parse_output["6920853"].should == "R"
      parse_output["6921265"].should == "C"
    end
  end
  describe "SimulationChecker.update_simulation_status" do
    before :each do
      @profile = Fabricate(:profile)
      @simulation = Fabricate(:simulation, :profile_id => @profile.id, :number => 1)
    end
    it "should set the state to queued if the passed in state is Q" do
      SimulationChecker.update_simulation_status(@simulation, "Q", "spec/support/simulations/missing_payoffs")
      Simulation.find(@simulation.id).state.should == "queued"
    end
    it "should set the state to running if the passed in state is R" do
      SimulationChecker.update_simulation_status(@simulation, "R", "spec/support/simulations/missing_payoffs")
      Simulation.find(@simulation.id).state.should == "running"
    end
    it "should queue a DataParser job if the passed in state is C and payoff_data exists" do
      SimulationChecker.update_simulation_status(@simulation, "C", "spec/support/simulations/success")
      DataParser.should have_queued(1)
    end
    it "should set the state to failed if the passed in state is C and payoff_data does not exist" do
      SimulationChecker.update_simulation_status(@simulation, "C", "spec/support/simulations/missing_payoffs")
      Simulation.find(@simulation.id).state.should == "failed"
    end
    it "should set the state to failed if the passed in state is C and out does not exist" do
      SimulationChecker.update_simulation_status(@simulation, "C", "spec/support/simulations/missing")
      Simulation.find(@simulation.id).state.should == "failed"
    end
    it "should queue a DataParser job if the passed in state is empty and payoff_data exists" do
      SimulationChecker.update_simulation_status(@simulation, "", "spec/support/simulations/success")
      DataParser.should have_queued(1)
    end
  end
end