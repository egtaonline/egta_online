require 'spec_helper'

describe "DeviationSchedulers" do
  shared_examples 'a deviation scheduler' do
    describe '#add_role' do
      before(:each) do
        scheduler.add_role('Bidder', 2)
      end

      it { scheduler.roles.count.should eql(1) }
      it { scheduler.deviating_roles.count.should eql(1) }
      it { scheduler.roles.first.should_not eql(scheduler.deviating_roles.first) }
    end

    describe '#remove_role' do
      before(:each) do
        scheduler.add_role('Bidder', 2)
        scheduler.remove_role('Bidder')
      end

      it { scheduler.roles.count.should eql(0) }
      it { scheduler.deviating_roles.count.should eql(0) }
    end

    describe '#add_deviating_strategy' do
      before(:each) do
        ProfileAssociater.should_receive(:perform_async).with(scheduler.id)
        scheduler.add_role('All', scheduler.size)
        scheduler.add_deviating_strategy('All', 'A')
      end

      it { scheduler.deviating_roles.where(name: 'All').first.strategies.first.should eql('A') }
      it { scheduler.roles.where(name: 'All').first.strategies.count.should eql(0) }
    end

    describe '#remove_deviating_strategy' do
      before(:each) do
        StrategyRemover.should_receive(:perform_async).with(scheduler.id)
        scheduler.add_role('All', 2)
        scheduler.add_deviating_strategy('All', 'A')
        scheduler.remove_deviating_strategy('All', 'A')
      end

      it { scheduler.deviating_roles.where(name: 'All').first.strategies.count.should eql(0) }
    end

    describe '#deviating_strategies_for' do
      before(:each) do
        scheduler.add_role('A', 1)
        scheduler.add_role('B', 2)
        scheduler.add_deviating_strategy('A', 'D')
        scheduler.add_deviating_strategy('A', 'C')
        scheduler.add_deviating_strategy('B', 'R')
        scheduler.add_strategy('B', 'F')
      end

      it { scheduler.deviating_strategies_for('A').should eql(['C', 'D']) }
      it { scheduler.deviating_strategies_for('B').should eql(['R']) }
    end

    describe '#available_strategies' do
      before(:each) do
        scheduler.simulator.stub(:strategies_for).with('A').and_return(['B', 'C', 'D'])
        scheduler.simulator.stub(:strategies_for).with('E').and_return(['F', 'G', 'H'])
        scheduler.stub(:strategies_for).with('A').and_return(['C'])
        scheduler.stub(:deviating_strategies_for).with('A').and_return(['D'])
        scheduler.stub(:strategies_for).with('E').and_return(['H'])
        scheduler.stub(:deviating_strategies_for).with('E').and_return(['F'])
      end

      it { scheduler.available_strategies('A').should eql(['B']) }
      it { scheduler.available_strategies('E').should eql(['G']) }
    end
  end

  describe DeviationScheduler do
    it { should embed_many(:deviating_roles) }

    it_behaves_like 'a deviation scheduler' do
      let!(:scheduler){ Fabricate(:deviation_scheduler) }
    end

    describe '#profile_space' do
      let(:scheduler){ Fabricate(:deviation_scheduler) }

      context 'a role is missing strategies' do
        before(:each) do
          scheduler.add_role('Buyer', 1)
          scheduler.add_strategy('Buyer', 'A')
          scheduler.add_role('Seller', 1)
          scheduler.add_deviating_strategy('Seller', 'B')
        end

        it { scheduler.profile_space.should eql([]) }
      end

      context 'non-empty deviating strategy sets' do
        context 'symmetry' do
          before(:each) do
            scheduler.add_role('All', 2)
            scheduler.add_strategy('All', 'A')
            scheduler.add_strategy('All', 'B')
            scheduler.add_deviating_strategy('All', 'C')
          end

          it { scheduler.profile_space.sort.should eql(['All: 2 A', 'All: 1 A, 1 B', 'All: 2 B', 'All: 1 A, 1 C', 'All: 1 B, 1 C'].sort) }
        end

        context 'asymmetry' do
          before(:each) do
            scheduler.update_attribute(:size, 3)
            scheduler.add_role('B', 2)
            scheduler.add_strategy('B', 'A')
            scheduler.add_strategy('B', 'B')
            scheduler.add_deviating_strategy('B', 'C')
            scheduler.add_role('S', 1)
            scheduler.add_strategy('S', 'A')
            scheduler.add_strategy('S', 'B')
            scheduler.add_deviating_strategy('S', 'C')
          end

          it { scheduler.profile_space.sort.should eql(['B: 2 A; S: 1 A', 'B: 2 A; S: 1 B', 'B: 1 A, 1 C; S: 1 A', 'B: 2 A; S: 1 C', 'B: 1 A, 1 C; S: 1 B',
                                                        'B: 1 A, 1 B; S: 1 A', 'B: 1 A, 1 B; S: 1 B', 'B: 1 B, 1 C; S: 1 B', 'B: 1 B, 1 C; S: 1 A', 'B: 1 A, 1 B; S: 1 C',
                                                        'B: 2 B; S: 1 A', 'B: 2 B; S: 1 B', 'B: 2 B; S: 1 C'].sort) }
        end
      end
    end
  end

  describe HierarchicalDeviationScheduler do
    it_behaves_like "a deviation scheduler" do
      let!(:scheduler){Fabricate(:hierarchical_deviation_scheduler, size: 2)}
    end
  end
end