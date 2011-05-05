require 'spec_helper'

describe "Schedulers" do
  describe "GET /schedulers" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get schedulers_path
      response.status.should be(200)
    end
  end
end
