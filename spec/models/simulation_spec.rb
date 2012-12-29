require 'spec_helper'

describe Simulation do
  let(:simulation){ Fabricate(:simulation) }
  
  describe 'a simulation fails' do
    before do
      ResqueSpec.reset!
      simulation.fail("could not transfer")
    end
    
    it "enqueues a check for rescheduling" do
      ProfileScheduler.should have_schedule_size_of(1)
      ProfileScheduler.should have_scheduled(simulation.profile.id).in(5 * 60)
    end
  end

  describe 'deleting a simulation from the database' do
    it "calls the backend cleanup routine" do
      Backend.should_receive(:clean_simulation).with(simulation)
      simulation.destroy
    end
  end
end