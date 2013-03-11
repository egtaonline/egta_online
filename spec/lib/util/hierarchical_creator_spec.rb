require 'util/hierarchical_creator'

describe HierarchicalCreator do
  describe 'expand_assignments' do
    it 'expands assignments consistent with role counts' do
      roles = [stub(name: 'EvenReduction', reduced_count: 1, count: 2),
               stub(name: 'UnevenReduction', reduced_count: 2, count: 5)]
      assignments = [[['EvenReduction', 'A'], ['UnevenReduction', 'B', 'C']]]
      HierarchicalCreator.expand_assignments(assignments, roles).should == [[['EvenReduction', 'A', 'A'], ['UnevenReduction', 'B', 'B', 'B', 'C', 'C']]]
    end
  end
end