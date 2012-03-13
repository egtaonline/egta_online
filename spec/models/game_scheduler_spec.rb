require 'spec_helper'

describe GameScheduler do
  before do
    ResqueSpec.reset!
  end
  
  shared_examples "a game scheduler" do
    
    describe "#destroy" do
      let!(:strategy){Fabricate(:strategy, :name => "A")}
      let!(:profile){Fabricate(:profile, :simulator => game_scheduler1.simulator)}
      it "should preserve profiles" do
        game_scheduler1.profiles << profile
        game_scheduler1.save!
        described_class.where(:size => 2).first.destroy
        Profile.count.should == 1
      end
    end

    describe "#add_strategy" do
      context "symmetric" do
        before :each do
          game_scheduler1.add_role("All", 2)
          game_scheduler1.add_strategy("All", "A")
          ResqueSpec.perform_all(:profile_actions)
        end

        it "should create profiles" do
          game_scheduler = described_class.where(:size => 2).first
          game_scheduler.profiles.size.should eql(1)
          game_scheduler.profiles.first.name.should eql("All: 2 A")
        end

        it "should create the subgame when more than one profile is added" do
          game_scheduler1.add_strategy("All", "B")
          ResqueSpec.perform_all(:profile_actions)
          game_scheduler = described_class.where(:size => 2).first
          game_scheduler.profiles.size.should eql(3)
          game_scheduler.profiles.collect{|p| p.name}.should eql(["All: 2 A", "All: 1 A, 1 B", "All: 2 B"])
        end
      end

      context "asymmetric" do
        it "should create the subgame when more than one profile is added" do
          game_scheduler2.add_role("Seller", 1)
          game_scheduler2.add_role("Bidder", 2)
          game_scheduler2.add_strategy("Bidder", "A")
          game_scheduler2.add_strategy("Seller", "C")
          game_scheduler2.add_strategy("Seller", "A")
          game_scheduler2.add_strategy("Bidder", "B")
          ResqueSpec.perform_all(:profile_actions)
          game_scheduler = described_class.where(:size => 3).first
          game_scheduler.profiles.size.should eql(6)
          game_scheduler.profiles.collect{|p| p.name}.should eql(["Bidder: 2 A; Seller: 1 A", "Bidder: 2 A; Seller: 1 C", "Bidder: 1 A, 1 B; Seller: 1 A", "Bidder: 1 A, 1 B; Seller: 1 C", "Bidder: 2 B; Seller: 1 A", "Bidder: 2 B; Seller: 1 C"])
        end
      end
    end

    describe "#remove_strategy" do
      it "should preserve profiles while removing the correct ones from the scheduler" do
        game_scheduler2.add_role("Seller", 1)
        game_scheduler2.add_role("Bidder", 2)
        game_scheduler2.add_strategy("Bidder", "A")
        game_scheduler2.add_strategy("Seller", "C")
        game_scheduler2.add_strategy("Seller", "A")
        game_scheduler2.add_strategy("Bidder", "B")
        ResqueSpec.perform_all(:profile_actions)
        game_scheduler = described_class.where(:size => 3).first
        game_scheduler.profiles.size.should eql(6)
        game_scheduler.remove_strategy("Seller", "A")
        game_scheduler.profiles.size.should eql(3)
        Profile.count.should eql(6)
      end
    end
  end
  
  describe GameScheduler do
    it_behaves_like "a game scheduler" do
      let!(:game_scheduler1){Fabricate(:game_scheduler)}
      let!(:game_scheduler2){Fabricate(:game_scheduler, :size => 3)}
    end
  end
  
  describe DeviationScheduler do
    it_behaves_like "a game scheduler" do
      let!(:game_scheduler1){Fabricate(:deviation_scheduler)}
      let!(:game_scheduler2){Fabricate(:deviation_scheduler, :size => 3)}
    end
  end
end