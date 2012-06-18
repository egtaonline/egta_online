require 'spec_helper'

describe RoleManipulator::Base do
  shared_examples 'a role-owner' do
    describe '#strategies_for' do
      before(:each) do
        role_manipulator.add_role('A')
        role_manipulator.add_role('B')
        role_manipulator.add_strategy('A', 'D')
        role_manipulator.add_strategy('A', 'C')
        role_manipulator.add_strategy('B', 'E')
      end
  
      it { role_manipulator.strategies_for('A').should eql(['C', 'D']) }
      it { role_manipulator.strategies_for('B').should eql(['E']) }
    end
    
    describe '#remove_role' do
      before(:each) do
        role_manipulator.add_role('A')
        role_manipulator.add_role('B')
        role_manipulator.remove_role('A')
      end
      
      it { role_manipulator.roles.collect{ |r| r.name }.should eql(['B']) }
    end
    
    describe '#remove_strategy' do
      before(:each) do
        role_manipulator.add_role('Bidder')
        role_manipulator.add_strategy('Bidder', 'A')
        role_manipulator.add_strategy('Seller', 'C')
        role_manipulator.add_strategy('Seller', 'A')
        role_manipulator.add_strategy('Bidder', 'B')
        role_manipulator.remove_strategy('Seller', 'A')
      end
      
      it { role_manipulator.strategies_for('Bidder').should eql(['A', 'B']) }
      it { role_manipulator.strategies_for('Seller').should eql(['C']) }
    end
  end
  
  describe Game do
    it_behaves_like "a role-owner" do
      let(:role_manipulator){ Fabricate(:game) }
    end
  end
  
  describe Simulator do
    it_behaves_like "a role-owner" do
      let(:role_manipulator){ Fabricate(:simulator) }
    end
  end
  
  describe GameScheduler do
    it_behaves_like "a role-owner" do
      let(:role_manipulator){ Fabricate(:game_scheduler) }
    end
  end
  
  describe DeviationScheduler do
    it_behaves_like "a role-owner" do
      let(:role_manipulator){ Fabricate(:deviation_scheduler) }
    end
  end
  
  describe HierarchicalScheduler do
    it_behaves_like "a role-owner" do
      let(:role_manipulator){ Fabricate(:hierarchical_scheduler) }
    end
  end
  
  describe HierarchicalDeviationScheduler do
    it_behaves_like "a role-owner" do
      let(:role_manipulator){ Fabricate(:hierarchical_scheduler) }
    end
  end
end