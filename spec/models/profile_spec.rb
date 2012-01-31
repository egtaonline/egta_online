require 'spec_helper'

describe Profile do
  describe "#name" do
    let!(:strategy1){Fabricate(:strategy, :name => "A")}
    let!(:strategy2){Fabricate(:strategy, :name => "B")}
    let!(:strategy3){Fabricate(:strategy, :name => "C")}
    let!(:profile){Fabricate(:profile, :proto_string => "Buyer: 1, 1, 2, 3; Seller: 2, 2, 3, 3")}
    it {profile.name.should == "Buyer: 2 A, 1 B, 1 C; Seller: 2 B, 2 C"}
  end
  
  describe "convert_to_proto_string" do
    before do
      Fabricate(:strategy, :name => "A", :number => 1)
      Fabricate(:strategy, :name => "B", :number => 2)
    end
    it "should convert to a valid proto_string" do
      Profile.convert_to_proto_string("Bidder: A, A, B; Seller: A, B, B").should == "Bidder: 1, 1, 2; Seller: 1, 2, 2"
      Profile.convert_to_proto_string("Bidder: asdfw; asdf").should == ""
    end
  end
  
  describe "size_of_profile" do
    it "should count the number of players with assignments in the profile" do
      Profile.size_of_profile("Bidder: A, A, B; Seller: A, B, B").should == 6
      Profile.size_of_profile("All: A, A").should == 2
    end
  end
end