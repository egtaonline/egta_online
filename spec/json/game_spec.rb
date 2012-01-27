require 'spec_helper'

describe Game do
  describe "#to_json" do
    let!(:strategy){Fabricate(:strategy, :name => "A", :number => 1)}
    let!(:sample_record){Fabricate(:sample_record, :payoffs => {"All" => {"A" => 23.0}}, :features => {"feature1" => 11.0})}
    let!(:game){Fabricate(:game, :simulator => sample_record.profile.simulator)}
    it "should look the way I expect" do
      game.features.create(:name => "feature1", :expected_value => 10.5)
      game.roles.create(:name => "All", :count => 2)
      game.roles.first.strategies << Strategy.where(:name => "A").first
      game.update_attribute(:profile_ids, Profile.where(simulator_id: game.simulator_id, parameter_hash: game.parameter_hash, size: game.size).map(&:_id))
      puts game.to_json(:root => true)
      str = "{\"classPath\":\"minimal-egat.datatypes.NormalFormGame\",\"object\":"
      str += "\"{\\\"roles\\\":[{\\\"name\\\":\\\"All\\\",\\\"numberOfPlayers\\\":2,\\\"actions\\\":[\\\"A\\\"]}],"
      str += "\\\"features\\\":[{\\\"name\\\":\\\"feature1\\\",\\\"expectedValue\\\":10.5}],"
      str += "\\\"profiles\\\":[{\\\"roleInstances\\\":{\\\"All\\\":{\\\"A\\\":2}},"
      str += "\\\"profileObservations\\\":[{\\\"payoffMap\\\":{\\\"All\\\":{\\\"A\\\":23.0}},\\\"featureMap\\\":{\\\"feature1\\\":11.0}}]}]}\"}"
      game.to_json(:root => true).should == str
    end
  end
end