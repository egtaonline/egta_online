require 'spec_helper'

describe SymmetryGroup do
  it { should be_embedded_in(:profile) }

  describe '#update_statistics' do
    it 'updates the symmetry groups payoff average and std deviation' do
      symmetry_group = Fabricate(:profile).symmetry_groups.first
      symmetry_group.update_statistics([10, 11])
      symmetry_group.payoff.should == 10.5
      symmetry_group.payoff_sd.should == 0.5
    end
  end
end