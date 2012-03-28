require 'spec_helper'

describe GenericScheduler do
  describe "#required_samples" do
    let!(:scheduler){Fabricate(:generic_scheduler)}
    let!(:profile){Fabricate(:profile, :simulator => scheduler.simulator)}
    let!(:profile1){Fabricate(:profile, :name => "All: 1 A, 1 B", :simulator => scheduler.simulator)}
    let!(:profile2){Fabricate(:profile, :name => "All: 2 B", :simulator => scheduler.simulator)}
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