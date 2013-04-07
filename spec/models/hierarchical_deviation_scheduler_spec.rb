require 'spec_helper'

describe HierarchicalDeviationScheduler do
  describe "#unassigned_player_count" do
    let(:scheduler){ Fabricate(:hierarchical_deviation_scheduler, size: 4) }
    before(:each) do
      scheduler.add_role("Bidder", 1)
    end
    it {scheduler.unassigned_player_count.should eql(3)}
  end

  describe '#profile_space' do
    context 'single role' do
      let(:scheduler){ Fabricate(:hierarchical_deviation_scheduler, size: 5) }

      before do
        scheduler.add_role('All', 5, 2)
        scheduler.add_strategy('All', 'A')
        scheduler.add_strategy('All', 'B')
        scheduler.add_deviating_strategy('All', 'C')
      end

      it { scheduler.profile_space.sort.should eql(['All: 5 A', 'All: 3 A, 2 B', 'All: 3 A, 2 C', 'All: 5 B', 'All: 3 B, 2 C'].sort) }
    end

    context 'multiple roles' do
      let(:scheduler){ Fabricate(:hierarchical_deviation_scheduler, size: 7) }

      before do
        scheduler.add_role('Role1', 3, 2)
        scheduler.add_role('Role2', 4, 2)
        scheduler.add_strategy('Role1', 'A')
        scheduler.add_strategy('Role1', 'B')
        scheduler.add_deviating_strategy('Role1', 'E')
        scheduler.add_strategy('Role2', 'C')
        scheduler.add_deviating_strategy('Role2', 'D')
      end

      it { scheduler.profile_space.sort.should eql(['Role1: 3 A; Role2: 4 C', 'Role1: 3 A; Role2: 2 C, 2 D', 'Role1: 2 A, 1 E; Role2: 4 C',
                                                    'Role1: 3 B; Role2: 4 C', 'Role1: 3 B; Role2: 2 C, 2 D', 'Role1: 2 B, 1 E; Role2: 4 C',
                                                    'Role1: 2 A, 1 B; Role2: 4 C', 'Role1: 2 A, 1 B; Role2: 2 C, 2 D'].sort) }
    end
  end
end