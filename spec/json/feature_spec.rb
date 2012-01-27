require 'spec_helper'

describe Feature do
  describe "#to_json" do
    let!(:feature){Fabricate(:feature, :name => "Price", :expected_value => 50.0)}
    it "should look the way I expect" do
      puts feature.to_json(:root => true)
      feature.to_json(:root => true).should == "{\"classPath\":\"minimal-egat.datatypes.Feature\",\"object\":\"{\\\"name\\\":\\\"Price\\\",\\\"expectedValue\\\":50.0}\"}"
    end
  end
end