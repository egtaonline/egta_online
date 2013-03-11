require 'unit_helper'
require 'util/assignment_formatter'

describe AssignmentFormatter do
  describe 'format_assignment' do
    let(:input){ [['First', 'A', 'B'], ['Second', 'D', 'D']] }
    
    it "converts an array-representation of the assignment to a string" do
      AssignmentFormatter.format_assignment(input).should == 'First: 1 A, 1 B; Second: 2 D'
    end
  end
end