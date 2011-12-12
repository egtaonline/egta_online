require 'spec_helper'

describe "#testing new data_parser" do
  before do
    ResqueSpec.reset!
    Account.create(username: "bcassell", active: true, skip: true)
  end

  let!(:simulator){Fabricate(:simulator, strategy_array: ['BayesianPricing:noRA:0'])}
  let!(:profile){Fabricate(:profile, simulator_id: simulator.id, parameter_hash: simulator.parameter_hash, size: 2, proto_string: 'All: BayesianPricing:noRA:0, BayesianPricing:noRA:0')}
  let!(:simulation){Simulation.create!(profile_id: profile.id, size: 5, state: "queued", number: 3, account_id: Account.last.id)}
  it "the new data parser should make sample_records" do
    DataParser.perform(3)
    profile = Profile.last
    puts "instances"
    puts Profile.last.role_instances.first.inspect
    profile.sample_records.count.should == 5
    profile.sample_count.should == 5
    arr = [2992.73172891313, 2991.94137519601, 2957.24141614658, 2957.60372235637, 2931.17122038337]
    avg = (eval arr.join('+'))/5
    role = profile.role_instances.where(name: "All").first
    role.strategy_instances.where(name: "BayesianPricing:noRA:0").first.payoff.should == avg
    role.strategy_instances.where(name: "BayesianPricing:noRA:0").first.payoff_std[3].round(7).should == Math.sqrt(0.25*arr.collect{|i| (i-avg)**2}.reduce(:+)).round(7)
    arr = [0.514654571782549, 0.51264473859671, 0.47771494416184, 0.484695863045296, 0.453008291906072]
    avg = (eval arr.join('+'))/5
    profile.feature_avgs["average_dividend"].should == avg
    profile.feature_stds["average_dividend"][3].round(7).should == Math.sqrt(0.25*arr.collect{|i| (i-avg)**2}.reduce(:+)).round(7)
  end
end