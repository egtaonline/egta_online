require 'spec_helper'

describe Game do

  it { should validate_presence_of :name }
  it { should validate_presence_of :size }
  it { should validate_presence_of :simulator_fullname }
  it { should validate_numericality_of(:size).to_allow(only_integer: true, greater_than: 0) }

  describe "#display_profiles" do
    context "symmetric game" do
      let(:profile){ Fabricate(:sampled_profile, assignment: 'All: 2 A') }
      let(:profile2){ Fabricate(:sampled_profile, simulator_instace: profile.simulator_instance, assignment: "All: 1 A, 1 B") }
      let(:game){ Fabricate(:game, simulator: profile.simulator_instance.simulator, configuration: profile.simulator_instance.configuration, size: 2) }

      before(:each) do
        game.add_role("All", 2)
        game.add_strategy("All", "A")
        game.reload
      end

      it { game.profiles.count.should eql(1) }
      it { game.profiles.first['assignment'].should eql(profile.assignment) }
    end
  end
end