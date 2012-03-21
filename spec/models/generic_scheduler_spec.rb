require 'spec_helper'

describe GenericScheduler do
  describe "#required_samples" do
    let!(:scheduler){Fabricate(:generic_scheduler)}
    let!(:strategy){Fabricate(:strategy, :name => "A", :number => 1)}
    let!(:strategy2){Fabricate(:strategy, :name => "B", :number => 2)}
    let!(:profile){Fabricate(:profile, :simulator => scheduler.simulator)}
    let!(:profile1){Fabricate(:profile, :proto_string => "All: 1, 2", :simulator => scheduler.simulator)}
    let!(:profile2){Fabricate(:profile, :proto_string => "All: 2, 2", :simulator => scheduler.simulator)}
    before do
      scheduler.add_profile(profile.name, 30)
      scheduler.add_profile(profile.name, 20)
      scheduler.add_profile(profile1.name, 10)
    end
    it {scheduler.required_samples(profile.id).should eql(20)}
    it {scheduler.required_samples(profile1.id).should eql(10)}
    it {scheduler.required_samples(profile2.id).should eql(0)}
  end
end