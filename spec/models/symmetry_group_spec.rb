require 'spec_helper'

describe SymmetryGroup do
  it { should be_embedded_in(:profile) }
  it { should validate_presence_of(:count) }
  it { should validate_numericality_of(:count).greater_than(0) }
  it { should validate_presence_of(:strategy) }
  it { should validate_uniqueness_of(:strategy).scoped_to(:role) }
  it { should validate_presence_of(:role) }
  it { should embed_many(:players) }
  
  let(:symmetry_group){ Fabricate(:symmetry_group_with_players) }
  subject{ symmetry_group }
  
  its(:payoff) { should eql(symmetry_group.players.map{ |player| player.payoff }.reduce(:+)/symmetry_group.players.count) }
  its(:payoff_sd) { should eql(symmetry_group.players.map{ |player| player.payoff }.to_scale.sd) }
end