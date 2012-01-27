require 'spec_helper'

describe Profile do
  describe "#to_json" do
    let!(:strategy){Fabricate(:strategy, :name => "A", :number => 1)}
    let!(:sample_record){Fabricate(:sample_record, :payoffs => {"All" => {"A" => 23.0}}, :features => {"feature1" => 11.0})}
    let!(:profile){sample_record.profile}
    it "should look the way I expect" do
      puts profile.to_json(:root => true)
      str = "{\"classPath\":\"minimal-egat.datatypes.Profile\",\"object\":"
      str += "\"{\\\"roleInstances\\\":{\\\"All\\\":{\\\"A\\\":2}},"
      str += "\\\"profileObservations\\\":[{\\\"payoffMap\\\":{\\\"All\\\":{\\\"A\\\":23.0}},\\\"featureMap\\\":{\\\"feature1\\\":11.0}}]}\"}"
      profile.to_json(:root => true).should == str
    end
  end
end