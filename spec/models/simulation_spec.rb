require 'spec_helper'

describe Simulation do
  before(:each) do
    ResqueSpec.reset!
  end

  context "a simulation has failed" do
    let!(:simulation){ Fabricate(:simulation) }

    before(:each) do
      simulation.failure!
    end

    it "enqueues a check for rescheduling" do
      ProfileScheduler.should have_schedule_size_of(1)
      ProfileScheduler.should have_scheduled(simulation.profile.id).in(5 * 60)
    end
  end

  context "a simulation count not transfer" do
    let!(:simulation){ Fabricate(:simulation) }

    before(:each) do
      simulation.fail("count not transfer")
    end

    it "enqueues a check for rescheduling" do
      ProfileScheduler.should have_schedule_size_of(1)
      ProfileScheduler.should have_scheduled(simulation.profile.id).in(5 * 60)
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