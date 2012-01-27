require 'spec_helper'

describe Profile do
  describe "#name" do
    let!(:strategy1){Fabricate(:strategy, :name => "A")}
    let!(:strategy2){Fabricate(:strategy, :name => "B")}
    let!(:strategy3){Fabricate(:strategy, :name => "C")}
    let!(:profile){Fabricate(:profile, :proto_string => "Buyer: 1, 1, 2, 3; Seller: 2, 2, 3, 3")}
    it {profile.name.should == "Buyer: 2 A, 1 B, 1 C; Seller: 2 B, 2 C"}
  end
end