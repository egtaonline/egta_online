require 'spec_helper'

describe Simulation do
  let(:simulation){ Fabricate(:simulation) }

  describe 'a simulation fails' do
    it "enqueues a check for rescheduling" do
      simulation.profile.should_receive(:try_scheduling)
      simulation.fail("could not transfer")
    end
  end

  describe 'deleting a simulation from the database' do
    it "calls the backend cleanup routine" do
      Backend.should_receive(:clean_simulation).with(simulation)
      simulation.destroy
    end
  end

  describe 'simulation_limit' do
    let(:simulations){ double("simulations") }

    before do
      Simulation.stub(:active).and_return(simulations)
    end

    context 'not close to the queue limit' do

      before do
        simulations.stub(:count).and_return(12)
      end

      it{ Simulation.simulation_limit.should eql(Backend.configuration.queue_quantity) }
    end

    context 'is close to queue limit' do
      before do
        simulations.stub(:count).and_return(983)
      end

      it{ Simulation.simulation_limit.should eql(16) }
    end
  end
end