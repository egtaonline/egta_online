require 'spec_helper'

describe "GameScheduler" do
  describe "#ensure profiles" do
    let!(:simulator) { Fabricate(:simulator) }
    let!(:run_time_configuration) { Fabricate(:run_time_configuration, :simulator_id => simulator.id) }
    let!(:profile) { Fabricate(:profile, :proto_string => ['A', 'A'].join(", "), :simulator_id => simulator.id, :run_time_configuration_id => run_time_configuration.id) }
    let!(:game_scheduler) { Fabricate(:game_scheduler, :simulator_id => simulator.id, :run_time_configuration_id => run_time_configuration.id) }
    specify { Profile.count.should == 1}
    describe "with 1 strategy" do
      before do
        game_scheduler.strategy_array << "A"
        game_scheduler.ensure_profiles
      end
      specify { Profile.count.should == 1}
    end
    describe "with 2 strategies" do
      before do
        game_scheduler.strategy_array << "A"
        game_scheduler.strategy_array << "B"
        game_scheduler.ensure_profiles
      end
      specify { Profile.count.should == 3}
    end
    describe "with 1 unschedulable profile" do
      let!(:profile) { Fabricate(:profile, :proto_string => ['C', 'C'].join(", "), :simulator_id => simulator.id, :run_time_configuration_id => run_time_configuration.id) }
      before do
        game_scheduler.strategy_array << "A"
        game_scheduler.strategy_array << "B"
        game_scheduler.ensure_profiles
      end
      specify { Profile.count.should == 4}
    end
  end
end