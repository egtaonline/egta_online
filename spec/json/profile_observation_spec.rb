require 'spec_helper'

describe SampleRecord do
  describe "#to_json" do
    let!(:strategy){Fabricate(:strategy, :name => "A", :number => 1)}
    let!(:sample_record){Fabricate(:sample_record, :payoffs => {"All" => {"A" => 23.0}}, :features => {"feature1" => 11.0})}
    it "should look the way I expect" do
      puts sample_record.to_json(:root => true)
      str = "{\"classPath\":\"minimal-egat.datatypes.ProfileObservation\",\"object\":"
      str += "\"{\\\"payoffMap\\\":{\\\"All\\\":{\\\"A\\\":23.0}},\\\"featureMap\\\":{\\\"feature1\\\":11.0}}\"}"
      sample_record.to_json(:root => true).should == str
    end
  end
end