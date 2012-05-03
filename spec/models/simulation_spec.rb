require 'spec_helper'

describe Simulation do
  before(:each) do
    ResqueSpec.reset!
  end
  
  context "a simulation has failed" do
    let!(:simulation){Fabricate(:simulation)}
    
    before(:each) do
      simulation.failure!
    end
    
    it "enqueues a check for rescheduling" do
      ProfileScheduler.should have_scheduled(simulation.profile.id).in(5 * 60)
    end
  end
end