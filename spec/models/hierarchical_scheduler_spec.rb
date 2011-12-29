require 'spec_helper'

describe HierarchicalScheduler do
  describe "validations" do
    let!(:simulator){Fabricate(:simulator)}
    it "should be considered invalid if agents_per_player does not divide size" do
      scheduler = Fabricate.build(:hierarchical_scheduler, :size => 8, :agents_per_player => 4)
      scheduler.valid?.should == true
      scheduler = Fabricate.build(:hierarchical_scheduler, :size => 8, :agents_per_player => 3)
      scheduler.valid?.should == false
    end
  end
end