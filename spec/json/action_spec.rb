require 'spec_helper'

describe Strategy do
  describe "#to_json" do
    let!(:action){Fabricate(:strategy, :number => 1, :name => "strat1")}
    it "should look the way I expect" do
      puts action.to_json(:root => true)
      action.to_json(:root => true).should == "{\"classPath\":\"minimal-egat.datatypes.Action\",\"object\":\"{\\\"number\\\":1,\\\"name\\\":\\\"strat1\\\"}\"}"
    end
  end
end