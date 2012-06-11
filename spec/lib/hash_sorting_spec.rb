require 'spec_helper'

describe "Hash#fully_sort" do
  let(:unsorted_hash){ { "B" => { "D" => 1, "E" => 2 }, "A" => { "G" => 3, "F" => 2 } } }
  it { unsorted_hash.fully_sort.inspect.should == { "A" => { "F" => 2, "G" => 3 }, "B" => { "D" => 1, "E" => 2 } }.inspect }
end