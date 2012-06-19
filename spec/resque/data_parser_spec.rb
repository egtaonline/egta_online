require 'spec_helper'

describe "#testing new data_parser" do
  before do
    ResqueSpec.reset!
    Account.new(username: "bcassell", active: true).save(validate: false)
  end

  let!(:profile){ Fabricate(:profile, assignment: 'All: 2 BayesianPricing:noRA:0') }
  let!(:simulation){ Simulation.create!(profile_id: profile.id, size: 5, state: 'queued', number: 3, account_id: Account.last.id) }
  it "the new data parser should make sample_records" do
    DataParser.perform(3)
    profile = Profile.last
    profile.sample_records.count.should == 5
    profile.sample_count.should == 5
    arr = [2992.73172891313, 2991.94137519601, 2957.24141614658, 2957.60372235637, 2931.17122038337]
    avg = (arr.reduce(:+))/5
    profile.payoff("All", "BayesianPricing:noRA:0") == avg
    profile.payoff_std("All", "BayesianPricing:noRA:0").round(7).should == Math.sqrt(0.25*arr.collect{|i| (i-avg)**2}.reduce(:+)).round(7)
  end
end