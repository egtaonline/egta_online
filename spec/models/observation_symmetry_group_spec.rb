require 'spec_helper'

describe ObservationSymmetryGroup do
  describe '#payoffs' do
    let(:symmetry_group){ Fabricate(:profile_with_observation).observations.first.observation_symmetry_groups.first }

    it 'provides an array of player payoffs' do
      symmetry_group.stub(:players).and_return([{ "p" => 11 }, { "p" => 12 }])
      symmetry_group.payoffs.should == [11, 12]
    end
  end
end