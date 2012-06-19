require 'spec_helper'

describe GameScheduler do
  it { should validate_numericality_of(:default_samples).to_allow(only_integer: true) }
  
  shared_examples 'a game scheduler' do
    describe '#required_samples' do
      let!(:profile){ Fabricate(:profile, :simulator => scheduler.simulator) }
      let!(:profile2){ Fabricate(:profile, :assignment => 'All: 2 B', :simulator => scheduler.simulator) }
      
      before do
        scheduler.profiles << profile
      end
      
      it {scheduler.required_samples(profile.id).should eql(scheduler.default_samples)}
      it {scheduler.required_samples(profile2.id).should eql(0)}
    end
    
    describe '#profile_space' do
      context 'an invalid role partition' do
        before(:each) do
          scheduler.add_role('Buyer', 1)
        end
        
        it { scheduler.profile_space.should eql([]) }
      end
      
      context 'symmetry' do
        before(:each) do
          scheduler.add_role('All', 2)
          scheduler.add_strategy('All', 'A')
          scheduler.add_strategy('All', 'B')
        end
      
        it { scheduler.profile_space.sort.should eql(['All: 2 A', 'All: 1 A, 1 B', 'All: 2 B'].sort) }
      end
      
      context 'role-symmetry' do
        before(:each) do
          scheduler.update_attribute(:size, 3)
          scheduler.add_role('B', 2)
          scheduler.add_strategy('B', 'A')
          scheduler.add_strategy('B', 'B')
          scheduler.add_role('S', 1)
          scheduler.add_strategy('S', 'A')
          scheduler.add_strategy('S', 'B')
        end
      
        it { scheduler.profile_space.sort.should eql(['B: 2 A; S: 1 A', 'B: 2 A; S: 1 B',
                                                      'B: 1 A, 1 B; S: 1 A', 'B: 1 A, 1 B; S: 1 B',
                                                      'B: 2 B; S: 1 A', 'B: 2 B; S: 1 B'].sort) }
      end
    end
  end
  
  describe GameScheduler do
    it_behaves_like "a game scheduler" do
      let(:scheduler){ Fabricate(:game_scheduler) }
    end
  end
  
  describe DeviationScheduler do
    it_behaves_like "a game scheduler" do
      let(:scheduler){ Fabricate(:deviation_scheduler) }
    end
  end
  
  describe HierarchicalScheduler do
    it_behaves_like "a game scheduler" do
      let(:scheduler){ Fabricate(:hierarchical_scheduler, size: 2, agents_per_player: 1) }
    end
  end
  
  describe HierarchicalDeviationScheduler do
    it_behaves_like "a game scheduler" do
      let(:scheduler){ Fabricate(:hierarchical_scheduler, size: 2, agents_per_player: 1) }
    end
  end
end