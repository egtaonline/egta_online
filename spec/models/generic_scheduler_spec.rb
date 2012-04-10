require 'spec_helper'

describe GenericScheduler do
  describe "#required_samples" do
    let!(:scheduler){Fabricate(:generic_scheduler)}
    let!(:profile){Fabricate(:profile, :simulator => scheduler.simulator)}
    let!(:profile1){Fabricate(:profile, :name => "All: 1 A, 1 B", :simulator => scheduler.simulator)}
    let!(:profile2){Fabricate(:profile, :name => "All: 2 B", :simulator => scheduler.simulator)}
    before do
      scheduler.add_profile(profile.name, 30)
      scheduler.add_profile(profile.name, 20)
      scheduler.add_profile(profile1.name, 10)
    end
    it {scheduler.required_samples(profile.id).should eql(20)}
    it {scheduler.required_samples(profile1.id).should eql(10)}
    it {scheduler.required_samples(profile2.id).should eql(0)}
  end
  
  describe "#remove_role" do
    let!(:scheduler){Fabricate(:generic_scheduler)}
    let!(:profile){Fabricate(:profile, :simulator => scheduler.simulator)}
    let!(:profile1){Fabricate(:profile, :name => "Bidder: 1 A; Seller: 1 B", :simulator => scheduler.simulator)}
    
    context "local" do
      before :each do
        simulator = scheduler.simulator
        simulator.add_strategy("All", "A")
        simulator.add_strategy("Bidder", "A")
        simulator.add_strategy("Seller", "B")
        scheduler.add_profile(profile.name, 30)
        scheduler.add_profile(profile1.name, 20)
        scheduler.remove_role("All")
      end
    
      it { scheduler.profiles.count.should eql(1) }
      it { scheduler.profiles.last.name.should eql(profile1.name) }
      it { scheduler.required_samples(profile1.id).should eql(20) }
      it { scheduler.required_samples(profile.id).should eql(0)}
    end
    context "simulator" do
      before :each do
        simulator = scheduler.simulator
        simulator.add_strategy("All", "A")
        simulator.add_strategy("Bidder", "A")
        simulator.add_strategy("Seller", "B")
        scheduler.add_profile(profile.name, 30)
        scheduler.add_profile(profile1.name, 20)
        simulator.remove_role("All")
      end
    
      it { scheduler.profiles.count.should eql(1) }
      it { scheduler.profiles.last.name.should eql(profile1.name) }
      it { scheduler.required_samples(profile1.id).should eql(20) }
      it { scheduler.required_samples(profile.id).should eql(0)}
    end
  end
  
  describe "#remove_strategy" do
    let!(:scheduler){Fabricate(:generic_scheduler)}
    let!(:profile){Fabricate(:profile, :simulator => scheduler.simulator)}
    let!(:profile1){Fabricate(:profile, :name => "Bidder: 1 A; Seller: 1 B", :simulator => scheduler.simulator)}
    let!(:profile2){Fabricate(:profile, :name => "All: 2 B", :simulator => scheduler.simulator)}
    
    context "local" do
      before :each do
        simulator = scheduler.simulator
        simulator.add_strategy("All", "A")
        simulator.add_strategy("Bidder", "A")
        simulator.add_strategy("Seller", "B")
        scheduler.add_profile(profile.name, 30)
        scheduler.add_profile(profile1.name, 20)
        scheduler.add_profile(profile2.name, 20)
        scheduler.remove_strategy("All", "A")
      end
    
      it { scheduler.profiles.count.should eql(2) }
      it { scheduler.profiles.last.name.should eql(profile2.name) }
      it { scheduler.required_samples(profile2.id).should eql(20) }
      it { scheduler.required_samples(profile.id).should eql(0) }
    end
    
    context "simulator" do
      before :each do
        simulator = scheduler.simulator
        simulator.add_strategy("All", "A")
        simulator.add_strategy("Bidder", "A")
        simulator.add_strategy("Seller", "B")
        scheduler.add_profile(profile.name, 30)
        scheduler.add_profile(profile1.name, 20)
        scheduler.add_profile(profile2.name, 20)
        simulator.remove_strategy("All", "A")
      end
    
      it { scheduler.profiles.count.should eql(2) }
      it { scheduler.profiles.last.name.should eql(profile2.name) }
      it { scheduler.required_samples(profile2.id).should eql(20) }
      it { scheduler.required_samples(profile.id).should eql(0)}
    end
  end
end