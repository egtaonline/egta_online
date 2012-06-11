require 'spec_helper'

describe Scheduler do
  
  it { should have_one :configuration }
  
  shared_examples "a scheduler" do
    context "creation" do
      it "should set simulator_fullname field" do
        scheduler.simulator_fullname.should eql(Simulator.last.fullname)
      end
    end
  end
  
  describe GameScheduler do
    it_behaves_like "a scheduler" do
      let!(:scheduler){Fabricate(:game_scheduler)}
    end
  end
  
  describe HierarchicalScheduler do
    it_behaves_like "a scheduler" do
      let!(:scheduler){Fabricate(:hierarchical_scheduler)}
    end
  end
  
  describe DeviationScheduler do
    it_behaves_like "a scheduler" do
      let!(:scheduler){Fabricate(:deviation_scheduler)}
    end
  end
end