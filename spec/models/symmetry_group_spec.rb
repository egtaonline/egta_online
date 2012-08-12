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
  
  its(:payoff) { should eql(symmetry_group.players.map{ |player| player.payoff }.reduce(:+).to_f/symmetry_group.players.count) }
  its(:payoff_sd) { should eql(Math.sqrt(symmetry_group.players.map{ |player| player.payoff**2.0 }.reduce(:+).to_f/symmetry_group.players.count-(symmetry_group.players.map{ |player| player.payoff }.reduce(:+).to_f/symmetry_group.players.count)**2.0)) }
  
  describe "payoff_for" do
    before do
      symmetry_group.players.create(payoff: 234, observation_id: 2, features: {})
      symmetry_group.players.create(payoff: 245, observation_id: 2, features: {})
    end
    
    it { symmetry_group.payoff_for(2).should eql(239.5) }
  end
end