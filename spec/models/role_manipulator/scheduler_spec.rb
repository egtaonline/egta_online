require 'spec_helper'

describe RoleManipulator::Scheduler do
  shared_examples 'a role-based scheduler' do
    describe '#add_strategy' do
      it 'triggers the profile space calculations' do
        ProfileAssociater.should_receive(:perform_async).with(scheduler.id)
        scheduler.add_role('All', 2)
        scheduler.add_strategy('All', 'A')
      end
    end

    describe '#remove_role' do
      let(:profile){ Fabricate(:profile, simulator: scheduler.simulator) }

      before(:each) do
        scheduler.add_role('All', 2)
        profile.schedulers << scheduler
      end

      it 'removes profiles if the role is non-empty' do
        scheduler.remove_role('All')
        Profile.with_scheduler(scheduler).count.should eql(0)
      end

      it 'does not remove profiles if the role does not exist' do
        scheduler.remove_role('Market Maker')
        Profile.with_scheduler(scheduler).to_a.should eql([profile])
      end
    end

    describe '#remove_strategy' do
      before(:each) do
        scheduler.add_role('A', 2)
      end

      context 'when role is present on the scheduler' do
        it 'triggers profile space calculations' do
          StrategyRemover.should_receive(:perform_async).with(scheduler.id)
          scheduler.remove_strategy('A', 'B')
        end
      end

      context 'when role is not present on the scheduler' do
        it 'does not trigger profile space calculations' do
          StrategyRemover.should_not_receive(:perform_async)
          scheduler.remove_strategy('B', 'C')
        end
      end
    end
  end

  describe GameScheduler do
    it_behaves_like "a role-based scheduler" do
      let(:scheduler){ Fabricate(:game_scheduler) }
    end
  end

  describe DeviationScheduler do
    it_behaves_like "a role-based scheduler" do
      let(:scheduler){ Fabricate(:deviation_scheduler) }
    end
  end

  describe HierarchicalScheduler do
    it_behaves_like "a role-based scheduler" do
      let(:scheduler){ Fabricate(:hierarchical_scheduler, size: 2) }
    end
  end

  describe HierarchicalDeviationScheduler do
    it_behaves_like "a role-based scheduler" do
      let(:scheduler){ Fabricate(:hierarchical_scheduler, size: 2) }
    end
  end
end