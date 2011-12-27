require 'spec_helper'

describe Profile do
  describe "#name" do
    let!(:simulator){Fabricate(:simulator)}
    let!(:profile){Fabricate(:profile, :simulator_id => simulator.id, :proto_string => "Buyer: A, A, B, C; Seller: B, B, C, C")}
    it {profile.name.should == "Buyer: 2 A, 1 B, 1 C; Seller: 2 B, 2 C"}
  end
end