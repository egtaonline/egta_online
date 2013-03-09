require 'unit_helper'
require 'util/subgame_creator'

describe SubgameCreator do
  describe 'subgame_profiles' do
    let(:formatter){ fire_replaced_class_double('AssignmentFormatter') }

    it "returns an array of profile assignments consistent with an array with a single role" do
      roles = [stub(name: 'All', strategies: ['A', 'B'], reduced_count: 2)]
      formatter.should_receive(:format_assignments).with([[['All', 'A', 'A']], [['All', 'A', 'B']], [['All', 'B', 'B']]])
      SubgameCreator.subgame_assignments(roles, formatter)
    end

    it "returns an array of profile assignments consistent with an array with multiple roles" do
      roles = [stub(name: 'First', strategies: ['A', 'B'], reduced_count: 1),
               stub(name: 'Second', strategies: ['D'], reduced_count: 2)]
      formatter.should_receive(:format_assignments).with([[['First', 'A'], ['Second', 'D', 'D']], [['First', 'B'], ['Second', 'D', 'D']]])
      SubgameCreator.subgame_assignments(roles, formatter)
    end
  end
end