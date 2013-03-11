require 'unit_helper'
require 'util/deviation_creator'

describe DeviationCreator do
  describe 'deviation_assignments' do
    it "returns assignments for single player deviations" do
      roles = [stub(name: 'All', strategies: ['A', 'B'], reduced_count: 2)]
      deviating_roles = [stub(name: 'All', strategies: ['C', 'D'], reduced_count: 2)]
      deviation_assignments = DeviationCreator.deviation_assignments(roles, deviating_roles)
      deviation_assignments.should == [[['All', 'A', 'C']],
                                       [['All', 'A', 'D']],
                                       [['All', 'B', 'C']],
                                       [['All', 'B', 'D']]]
    end

    it "returns assignments that deviate from a target set for multiple roles" do
      roles = [stub(name: 'First', strategies: ['A'], reduced_count: 1),
               stub(name: 'Second', strategies: ['D'], reduced_count: 2)]
      deviating_roles = [stub(name: 'First', strategies: ['E'], reduced_count: 1),
                         stub(name: 'Second', strategies: ['F', 'G'], reduced_count: 2)]
      deviation_assignments = DeviationCreator.deviation_assignments(roles, deviating_roles)
      deviation_assignments.should == [[['First', 'E'], ['Second', 'D', 'D']],
                                       [['First', 'A'], ['Second', 'D', 'F']],
                                       [['First', 'A'], ['Second', 'D', 'G']]]
    end
  end
end