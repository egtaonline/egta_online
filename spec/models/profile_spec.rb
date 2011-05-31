require 'spec_helper'

#these are really describing symmetric profiles for now
describe Profile do
  describe "#initialize" do
    let!(:simulator) { Fabricate(:simulator) }
    let!(:profile) { Profile.create!(:simulator_id => simulator.id, :proto_string => ['A', 'A', 'B'].join(", ")) }
    specify { profile.profile_entries.count.should == 2}
    specify { profile.profile_entries.collect {|pe| pe.name}.sort.should == ["A: 2", "B: 1"] }
    specify { profile.proto_string.should == ['A', 'A', 'B'].join(", ")}
    specify { Profile.where(:proto_string => ['A', 'A', 'B'].join(", ")).count.should == 1}
  end
end