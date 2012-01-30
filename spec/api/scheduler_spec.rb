require 'spec_helper'

describe "/api/schedulers", :type => :api do
  let(:user) { Fabricate(:user) }
  let(:token) { user.authentication_token }
  before do
    @scheduler = Fabricate(:api_scheduler)
  end
  
  context "viewing schedulers" do
    let(:url) {"/api/schedulers"}
    it "json" do
      get "#{url}.json", :token => token
      schedulers_json = ApiScheduler.all.to_json
      last_response.body.should eql(schedulers_json)
      last_response.status.should eql(200)
      schedulers = JSON.parse(last_response.body)
      schedulers.any? do |s|
        s["name"] == "generic"
      end.should be_true
    end
  end
  
  context "adding a new profile" do
    let(:url) {"/api/schedulers/#{@scheduler.id}"}
    
    before do
      Fabricate(:strategy, :name => "A", :number => 1)
      Fabricate(:strategy, :name => "B", :number => 2)
    end
    it "should create a profile if the profile name is valid" do
      post "#{url}/add_profile.json", :token => token, :profile_name => "Bidder: A, A; Seller: B, B"
      puts last_response.body
      Profile.where(:proto_string => "Bidder: 1, 1; Seller: 2, 2").count.should == 1
    end
  end
end