require 'spec_helper'

describe Profile do
  it { should embed_many :symmetry_groups }
  it { should embed_many :observations }

  describe "uniqueness validation" do
    let!(:existing_profile){ Fabricate(:profile, assignment: "A: 1 StratA, 1 StratB; B: 2 StratC") }
    let!(:new_profile){ Fabricate.build(:profile, simulator_instance: existing_profile.simulator_instance,
                                                 assignment: "B: 2 StratC; A: 1 StratB, 1 StratA") }
    it "should identify violations of the uniqueness constraints" do
      new_profile.valid?.should eql(false)
      new_profile.errors[:assignment].should eql(["is already taken"])
    end
  end

  describe '#update_sample_count' do
    it 'sets the sample count field to the number of observations' do
      profile = Fabricate(:profile)
      profile.observations << Observation.new
      profile.update_sample_count
      profile.reload.sample_count.should == 1
    end
  end

  describe '#payoffs_for' do
    it 'returns an array of all the payoffs matching the appropriate symmetry_group' do
      profile = Fabricate(:profile, assignment: "A: 1 StratA, 1 StratB; B: 2 StratC")
      symmetry_group = profile.symmetry_groups.last
      profile.observations.create(observation_symmetry_groups: [{ players: [{ "p" => 100 }], payoff: 100, payoff_sd: 0.0 },
                                                                { players: [{ "p" => 100 }], payoff: 100, payoff_sd: 0.0 },
                                                                { players: [{ "p" => 100 }, { "p" => 200 }], payoff: 150, payoff_sd: Math.sqrt(3000) }])
      profile.observations.create(observation_symmetry_groups: [{ players: [{ "p" => 100 }], payoff: 100, payoff_sd: 0.0 },
                                                                { players: [{ "p" => 100 }], payoff: 100, payoff_sd: 0.0 },
                                                                { players: [{ "p" => 100 }, { "p" => 200 }], payoff: 150, payoff_sd: Math.sqrt(3000) }])
      profile.reload.payoffs_for(symmetry_group).should == [100.0, 200.0, 100.0, 200.0]
    end
  end
end