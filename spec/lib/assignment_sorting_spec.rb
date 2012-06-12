require 'spec_helper'

describe "String#assignment_sort" do
  let(:unsorted_string){ "B: 1 D, 2 E; A: 3 G, 2 F" }
  it { unsorted_string.assignment_sort.should == "A: 2 F, 3 G; B: 1 D, 2 E" }
end