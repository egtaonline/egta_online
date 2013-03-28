require 'spec_helper'

describe Simulator do

  describe "#location" do
    let(:simulator){Fabricate(:simulator)}
    it { simulator.location.should eql("#{Rails.root}/simulator_uploads/#{simulator.name}-#{simulator.version}") }
  end

  describe "setup and validation" do
    it "should replace any existing copy" do
      # Setup fake simulator
      system("mkdir -p #{Rails.root}/simulator_uploads/epp_sim-test/epp_sim/fakery")
      simulator = Fabricate(:simulator_realistic)
      File.exists?("#{Rails.root}/simulator_uploads/epp_sim-test/epp_sim/fakery").should eql(false)
      File.exists?("#{Rails.root}/simulator_uploads/epp_sim-test/epp_sim/defaults.json").should eql(true)
    end

    context "the simulator is valid" do
      let(:simulator){ Fabricate(:simulator_realistic) }

      before do
        SimulatorInitializer.should_receive(:perform_async).with(simulator.id)
      end

      it { simulator.configuration["number of agents"].should eql(120) }
    end

    it "should inform the user of a malformed defaults.json and a missing script/batch file" do
      simulator = Fabricate.build(:simulator_realistic, :name => "fake2", :simulator_source => File.new("#{Rails.root}/spec/support/fake2.zip"))
      simulator.should have(2).errors_on(:simulator_source)
      simulator.errors[:simulator_source].should include("had a malformed defaults.json file.")
      simulator.errors[:simulator_source].should include("did not find script/batch within #{simulator.location}/#{simulator.name}")
    end
  end
end