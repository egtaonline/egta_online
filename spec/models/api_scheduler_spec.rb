require 'spec_helper'

describe ApiScheduler do
  describe "convert_to_proto_string" do
    before do
      Fabricate(:strategy, :name => "A", :number => 1)
      Fabricate(:strategy, :name => "B", :number => 2)
    end
    it "should convert to a valid proto_string" do
      ApiScheduler.convert_to_proto_string("Bidder: A, A, B; Seller: A, B, B").should == "Bidder: 1, 1, 2; Seller: 1, 2, 2"
      ApiScheduler.convert_to_proto_string("Bidder: asdfw; asdf").should == ""
    end
  end
  
  describe "size_of_profile" do
    it "should count the number of players with assignments in the profile" do
      ApiScheduler.size_of_profile("Bidder: A, A, B; Seller: A, B, B").should == 6
      ApiScheduler.size_of_profile("All: A, A").should == 2
    end
  end
end