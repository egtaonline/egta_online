require 'spec_helper'

describe "#testing new data_parser" do
  before do
    ResqueSpec.reset!
    Account.new(username: "bcassell", active: true).save(:validate => false)
  end

  let!(:profile){Fabricate(:profile, :name => "All: 2 BayesianPricing:noRA:0")}
  let!(:simulation){Simulation.create!(profile_id: profile.id, size: 5, state: "queued", number: 3, account_id: Account.last.id)}
  it "the new data parser should make sample_records" do
    DataParser.perform(3)
    profile = Profile.last
    profile.sample_records.count.should == 5
    profile.sample_count.should == 5
    arr = [2992.73172891313, 2991.94137519601, 2957.24141614658, 2957.60372235637, 2931.17122038337]
    avg = (eval arr.join('+'))/5
    role = profile.role_instances.where(name: "All").first
    role.strategy_instances.where(:name => "BayesianPricing:noRA:0").first.payoff.round(7).should eql(avg.round(7))
    role.strategy_instances.where(:name => "BayesianPricing:noRA:0").first.payoff_sd.round(7).should == Math.sqrt(0.25*arr.collect{|i| (i-avg)**2}.reduce(:+)).round(7)
    arr = [0.514654571782549, 0.51264473859671, 0.47771494416184, 0.484695863045296, 0.453008291906072]
    avg = (eval arr.join('+'))/5
  end
end