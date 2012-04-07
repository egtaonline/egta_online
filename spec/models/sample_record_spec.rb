require 'spec_helper'

describe SampleRecord do
  context "a profile with an existing sample record" do
    let!(:profile){ Fabricate(:profile) }
    let!(:sample_record){ Fabricate(:sample_record, :profile => profile)}
    
    describe "adding a sample record" do
      before(:each) do
        @sample2 = Fabricate(:sample_record, :profile => profile)
        @role = profile.role_instances.first
        @strategy = @role.strategy_instances.first
      end
      it { profile.sample_count.should eql(2) }
      it "should calculate the correct payoff average" do
        average = (sample_record.payoffs[@role.name][@strategy.name]+@sample2.payoffs[@role.name][@strategy.name])/2.0
        profile.payoff(@role.name, @strategy.name).should eql(average)
      end
      it "should calculate the correct payoff std" do
        var = sample_record.payoffs[@role.name][@strategy.name]**2.0+@sample2.payoffs[@role.name][@strategy.name]**2.0-2.0*((sample_record.payoffs[@role.name][@strategy.name]+@sample2.payoffs[@role.name][@strategy.name])/2.0)**2.0
        profile.payoff_std(@role.name, @strategy.name).should eql(Math.sqrt(var))
      end
    end
  end
end