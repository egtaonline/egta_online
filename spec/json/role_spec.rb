require 'spec_helper'

describe Role do
  describe "#to_json" do
    let!(:role){Fabricate(:role, :role_owner => Fabricate(:game), :name => "All", :count => 2)}
    it "should look the way I expect" do
      role.strategies << Fabricate(:strategy, :name => "strat1", :number => 1)
      role.strategies << Fabricate(:strategy, :name => "strat2", :number => 2)
      puts role.to_json(:root => true)
      str = "{\"classPath\":\"minimal-egat.datatypes.Role\",\"object\":"
      str += "\"{\\\"name\\\":\\\"All\\\",\\\"numberOfPlayers\\\":2,\\\"actions\\\":[\\\"strat1\\\",\\\"strat2\\\"]}\"}"
      role.to_json(:root => true).should == str
    end
  end
end