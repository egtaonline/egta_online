require 'unit_helper'
require 'util/subgame_creator'

describe SubgameCreator do
  describe 'subgame_assignments' do
    it "returns an array of profile assignments consistent with an array with a single role" do
      roles = [stub(name: 'All', strategies: ['A', 'B'], reduced_count: 2)]
      SubgameCreator.subgame_assignments(roles).should == [[['All', 'A', 'A']],
                                                           [['All', 'A', 'B']],
                                                           [['All', 'B', 'B']]]
    end

    it "returns an array of profile assignments consistent with an array with multiple roles" do
      roles = [stub(name: 'First', strategies: ['A', 'B'], reduced_count: 1),
               stub(name: 'Second', strategies: ['D'], reduced_count: 2)]
      SubgameCreator.subgame_assignments(roles).should == [[['First', 'A'], ['Second', 'D', 'D']],
                                                           [['First', 'B'], ['Second', 'D', 'D']]]

    end
  end
end