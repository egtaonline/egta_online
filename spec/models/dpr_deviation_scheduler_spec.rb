require 'spec_helper'

describe DprDeviationScheduler do
  describe '#profile_space' do
    context 'single role' do
      let(:scheduler){ Fabricate(:dpr_deviation_scheduler, size: 3) }

      before do
        scheduler.add_role('All', 3, 2)
        scheduler.add_strategy('All', 'A')
        scheduler.add_strategy('All', 'B')
        scheduler.add_deviating_strategy('All', 'C')
      end

      it { scheduler.profile_space.sort.should eql(['All: 3 A', 'All: 2 A, 1 B', 'All: 1 A, 2 B', 'All: 2 A, 1 C', 'All: 1 A, 2 C', 'All: 3 B', 'All: 2 B, 1 C', 'All: 1 B, 2 C'].sort) }
    end

    context 'multiple roles' do
      let(:scheduler){ Fabricate(:dpr_deviation_scheduler, size: 7) }

      before do
        scheduler.add_role('Role1', 3, 2)
        scheduler.add_role('Role2', 4, 3)
        scheduler.add_strategy('Role1', 'A')
        scheduler.add_strategy('Role1', 'B')
        scheduler.add_deviating_strategy('Role1', 'E')
        scheduler.add_strategy('Role2', 'C')
        scheduler.add_deviating_strategy('Role2', 'D')
      end

      it { scheduler.profile_space.sort.should eql(['Role1: 3 A; Role2: 4 C', 'Role1: 1 A, 2 B; Role2: 4 C', 'Role1: 2 A, 1 B; Role2: 4 C', 'Role1: 3 B; Role2: 4 C',
                                                    'Role1: 2 A, 1 E; Role2: 4 C', 'Role1: 1 A, 2 E; Role2: 4 C', 'Role1: 1 B, 2 E; Role2: 4 C', 'Role1: 2 B, 1 E; Role2: 4 C',
                                                    'Role1: 3 A; Role2: 3 C, 1 D', 'Role1: 2 A, 1 B; Role2: 3 C, 1 D', 'Role1: 1 A, 2 B; Role2: 3 C, 1 D', 'Role1: 3 B; Role2: 3 C, 1 D'].sort)}
    end
  end
end