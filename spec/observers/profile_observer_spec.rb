require 'spec_helper'

describe ProfileObserver do
  describe "converts assignments into symmetry groups" do
    context "fully symmetric" do
      let(:profile){ Fabricate(:profile, :assignment => "All: 2 StratB, 3 StratA") }
      it { profile.symmetry_groups.count.should eql(2) }
      it { profile.symmetry_groups.each{ |s| s.role.should eql("All") } }
      it { profile.symmetry_groups.collect{ |s| s.strategy } =~ ["StratA", "StratB"] }
      it { profile.size.should eql(5) }
      it { profile["role_All_count"].should eql(5) }
    end
    
    context "role symmetric" do
      let(:profile){ Fabricate(:profile, :assignment => "Seller: 2 StratB, 3 StratA; Buyer: 2 StratB") }
      it { profile.symmetry_groups.count.should eql(3) }
      it { profile.symmetry_groups.where(role: "Seller").count.should eql(2) }
      it { profile.symmetry_groups.where(role: "Buyer").count.should eql(1) }
      it { profile.symmetry_groups.where(role: "Seller").collect{ |s| s.strategy } =~ ["StratA", "StratB"] }
      it { profile.symmetry_groups.where(role: "Buyer").first.strategy.should eql("StratB") }
      it { profile.size.should eql(7) }
      it { profile["role_Seller_count"].should eql(5) }
      it { profile["role_Buyer_count"].should eql(2) }
    end
  end
  
  describe "orders assignments before validation" do
    let(:profile){ Fabricate(:profile, :assignment => "Seller: 2 StratB, 3 StratA; Buyer: 2 StratB") }
    it { profile.assignment.should == "Buyer: 2 StratB; Seller: 3 StratA, 2 StratB" }
  end
end