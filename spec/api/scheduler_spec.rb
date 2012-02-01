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

  context "creating a scheduler" do
    let(:url) {"/api/schedulers"}
    
    it "successful JSON" do
      simulator = Simulator.last
      post "#{url}.json", :token => token, :scheduler => {:simulator_id => simulator.id, :name => "test",
                                                          :active => true, :process_memory => 1000,
                                                          :time_per_sample => 120, :samples_per_simulation => 30,
                                                          :max_samples => 30, :parameter_hash => simulator.parameter_hash,
                                                          :nodes => 1}
      scheduler = Scheduler.last
      scheduler.simulator.should == simulator
      route = "/api/schedulers/#{scheduler.id}"
      last_response.status.should eql(201)
      last_response.headers["Location"].should eql(route)
      last_response.body.should eql(scheduler.to_json)
    end
    
    it "unsuccessful JSON" do
      simulator = Simulator.last
      post "#{url}.json", :token => token, :scheduler => {:simulator_id => simulator.id, :name => "test",
                                                          :active => true,
                                                          :time_per_sample => 120, :samples_per_simulation => 30,
                                                          :max_samples => 30, :parameter_hash => simulator.parameter_hash,
                                                          :nodes => 1}
      last_response.status.should eql(422)
      errors = {"process_memory" => ["can't be blank","is not a number"]}.to_json
      last_response.body.should eql(errors)
    end
  end
  
  context "show" do
    let(:url) {"/api/schedulers/#{@scheduler.id}"}
    
    it "JSON" do
      get "#{url}.json", :token => token
      last_response.body.should eql(@scheduler.to_json)
      last_response.status.should eql(200)
    end
  end
  
  context "find" do
    let(:url) {"/api/schedulers"}
    
    it "JSON search" do
      get "#{url}/find.json", :token => token, :criteria => {:name => "generic"}
      last_response.body.should eql([@scheduler].to_json)
      last_response.status.should eql(200)
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
      Profile.where(:proto_string => "Bidder: 1, 1; Seller: 2, 2").count.should == 1
    end
  end
  
  context "adding a new profile to an invalid scheduler" do
    let(:url) {"/api/schedulers/234"}
    
    before do
      Fabricate(:strategy, :name => "A", :number => 1)
      Fabricate(:strategy, :name => "B", :number => 2)
    end
    it "should error out if the scheduler is invalid" do
      post "#{url}/add_profile.json", :token => token, :profile_name => "Bidder: A, A; Seller: B, B"
      Profile.where(:proto_string => "Bidder: 1, 1; Seller: 2, 2").count.should == 0
      last_response.status.should eql(404)      
    end
  end
  
  context "adding an invalid profile" do
    let(:url) {"/api/schedulers/#{@scheduler.id}"}
    
    before do
      Fabricate(:strategy, :name => "A", :number => 1)
      Fabricate(:strategy, :name => "B", :number => 2)
    end
    it "should not create a profile if the profile name is invalid" do
      post "#{url}/add_profile.json", :token => token, :profile_name => "Bidder: A, C; Seller: B, B"
      Profile.count.should == 0
      last_response.status.should eql(422)
    end
  end
end