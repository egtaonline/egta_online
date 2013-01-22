require 'spec_helper'

describe SymmetryGroup do
  it { should be_embedded_in(:role_strategy_partitionable) }
  it { should validate_presence_of(:count) }
  it { should validate_numericality_of(:count).greater_than(0) }
  it { should validate_presence_of(:strategy) }
  it { should validate_uniqueness_of(:strategy).scoped_to(:role) }
  it { should validate_presence_of(:role) }
  it { should embed_many(:players) }
  
  describe '#payoffs' do
    context 'when the symmetry group is on an observation' do
      let(:symmetry_group){ Fabricate(:profile_with_observation).observations.first.symmetry_groups.first }
      
      it 'provides an array of player payoffs' do
        symmetry_group.stub(:players).and_return([stub(payoff: 11), stub(payoff: 12)])
        symmetry_group.payoffs.should == [11, 12]
      end
    end
  end
  
  describe '#update_statistics' do
    it 'updates the symmetry groups payoff average and std deviation' do
      symmetry_group = Fabricate(:profile).symmetry_groups.first
      symmetry_group.update_statistics([10, 11])
      symmetry_group.payoff.should == 10.5
      symmetry_group.payoff_sd.should == 0.5
    end
  end
end