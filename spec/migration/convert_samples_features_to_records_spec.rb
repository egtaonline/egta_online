require 'spec_helper'

describe "Conversion from old samples to new samples" do
  before do
    ResqueSpec.reset!
  end

  it "should associate a profile to a game" do
    simulator = Fabricate(:simulator)
    profile = SymmetricProfile.create!(simulator_id: simulator.id, parameter_hash: simulator.parameter_hash, size: 2, proto_string: "A, B")
    ResqueSpec.perform_all(:profile_actions)
    profile.profile_entries.first.samples.create!(payoff: 1.0)
    profile.profile_entries.first.samples.create!(payoff: 1.2)
    profile.profile_entries.last.samples.create(payoff: 2.0)
    profile.profile_entries.last.samples.create(payoff: 1.9)
    profile.features.create!(name: "Test")
    profile.features.first.samples.create!(payoff: 0.6)
    profile.features.first.samples.create!(payoff: 0.7)
    Resque.enqueue(ConvertSamples, profile.id)
    ResqueSpec.perform_all("profile_actions")
    profile.sample_records.count.should == 2
    puts profile.sample_records.first.inspect
    profile.sample_records.first.payoffs["A"].should == 1.0
    profile.sample_records.first.payoffs["B"].should == 2.0
    profile.sample_records.last.payoffs["A"].should == 1.2
    profile.sample_records.last.payoffs["B"].should == 1.9
    profile.sample_records.first.features["Test"].should == 0.6
    profile.sample_records.last.features["Test"].should == 0.7
  end
end