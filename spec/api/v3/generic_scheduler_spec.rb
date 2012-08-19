require 'spec_helper'

describe "/api/v3/generic_schedulers", :type => :api do
  let(:user) { Fabricate(:user) }
  let(:token) { user.authentication_token }
  before do
    @scheduler = Fabricate(:generic_scheduler_with_roles)
  end
  
  let(:url) {"/api/v3/generic_schedulers"}
  
  context "creating a scheduler" do
    context "successful creation" do
      it "successful JSON" do
        simulator = Simulator.last
        post "#{url}.json", :auth_token => token, :scheduler => {:simulator_id => simulator.id, :name => "test",
                                                            :active => true, :process_memory => 1000, :size => 4,
                                                            :time_per_sample => 120, :samples_per_simulation => 30,
                                                            :default_samples => 30, :configuration => simulator.configuration,
                                                            :nodes => 1}
        scheduler = GenericScheduler.last
        scheduler.simulator.should == simulator
        route = "/api/v3/generic_schedulers/#{scheduler.id}"
        last_response.status.should eql(201)
        last_response.headers["Location"].should eql(route)
        last_response.body.should eql(scheduler.to_json)
      end
    end
    
    context "unsuccessful creation" do
      it "unsuccessful JSON" do
        simulator = Simulator.last
        post "#{url}.json", :auth_token => token, :scheduler => {:simulator_id => simulator.id, :name => "test",
                                                          :active => true, :size => 4,
                                                          :time_per_sample => 120, :samples_per_simulation => 30,
                                                          :default_samples => 30, :configuration => simulator.configuration,
                                                          :nodes => 1}
        last_response.status.should eql(422)
        errors = {"errors" => {"process_memory" => ["can't be blank","is not a number"]}}.to_json
        last_response.body.should eql(errors)
      end
      
      it "invalid request" do
        simulator = Simulator.last
        post "#{url}.json", :auth_token => token
        last_response.status.should eql(422)
        errors = {"errors" => {"default_samples" => ["is not a number"], "process_memory"=>["can't be blank","is not a number"],"name"=>["can't be blank"],"time_per_sample"=>["can't be blank","is not a number"],"samples_per_simulation"=>["can't be blank","is not a number"], "configuration" => ["can't be blank"], "size" => ["can't be blank"]}}.to_json
        last_response.body.should eql(errors)
      end
    end
  end

   context "update" do
     let(:url) {"/api/v3/generic_schedulers/#{@scheduler.id}"}
     
     it "successful JSON" do
       put "#{url}.json", :auth_token => token, :scheduler => {:time_per_sample => 60}
       @scheduler.reload
       @scheduler.time_per_sample.should eql(60)
       last_response.status.should eql(204)
       last_response.body.should eql("")
     end
     
     it "unsuccessful JSON" do
       put "#{url}.json", :auth_token => token, :scheduler => {:time_per_sample => ""}
       last_response.status.should eql(422)
       @scheduler.reload
       @scheduler.time_per_sample.should eql(60)
       errors = {"errors" => {:time_per_sample => ["can't be blank","is not a number"]}}.to_json
       last_response.body.should eql(errors)
     end
   end
   
   context "destroy" do
     let(:url) {"/api/v3/generic_schedulers/#{@scheduler.id}"}
     
     it "JSON" do
       delete "#{url}.json", :auth_token => token
       Scheduler.where(:id => @scheduler.id).count.should == 0
       last_response.status.should eql(204)
     end
   end
   
  context "adding a new profile" do
    let(:url) {"/api/v3/generic_schedulers/#{@scheduler.id}"}
     
    it "should create a profile if the profile name is valid" do
      post "#{url}/add_profile.json", :auth_token => token, :assignment => "Bidder: 2 A; Seller: 2 B", :sample_count => 10
      Profile.where(:assignment => "Bidder: 2 A; Seller: 2 B").count.should == 1
    end
    it "should only add the profile once, even if you invoke it multiple times" do
      post "#{url}/add_profile.json", :auth_token => token, :assignment => "Bidder: 2 A; Seller: 2 B", :sample_count => 10
      post "#{url}/add_profile.json", :auth_token => token, :assignment => "Bidder: 2 A; Seller: 2 B", :sample_count => 10
      Profile.where(:assignment => "Bidder: 2 A; Seller: 2 B").count.should eql(1)
      Scheduler.last.profiles.count.should eql(1)
    end
    it "should only add the profile once, even if you invoke it multiple times with rearrangements to the name" do
      post "#{url}/add_profile.json", :auth_token => token, :assignment => "Bidder: 1 A, 1 B; Seller: 2 B", :sample_count => 10
      post "#{url}/add_profile.json", :auth_token => token, :assignment => "Bidder: 1 B, 1 A; Seller: 2 B", :sample_count => 10
      post "#{url}/add_profile.json", :auth_token => token, :assignment => "Seller: 2 B; Bidder: 1 B, 1 A", :sample_count => 10
      post "#{url}/add_profile.json", :auth_token => token, :assignment => "Seller: 2 B; Bidder: 1 A, 1 B", :sample_count => 10
      Profile.where(:assignment => "Bidder: 1 A, 1 B; Seller: 2 B").count.should eql(1)
      Scheduler.last.profiles.count.should eql(1)
    end
  end
  
  context "removing a profile" do
    let(:url) {"/api/v3/generic_schedulers/#{@scheduler.id}"}
    
    context "the profile exists" do
      before :each do
        post "#{url}/add_profile.json", :auth_token => token, :assignment => "Bidder: 2 A; Seller: 2 B", :sample_count => 10
        @profile = Scheduler.last.profiles.last
        post "#{url}/remove_profile.json", :auth_token => token, :profile_id => @profile.id
        @scheduler.reload
      end
      
      it "should remove the profile from the scheduler" do
        @scheduler.profiles.count.should eql(0)
        @scheduler.required_samples(@profile).should eql(0)
      end
      
      it "should not destroy the profile" do
        Profile.find(@profile.id).should eql(@profile)
      end
    end
    
    context "another profile exists" do
      before :each do
        post "#{url}/add_profile.json", :auth_token => token, :assignment => "Bidder: 2 A; Seller: 2 B", :sample_count => 10
        post "#{url}/add_profile.json", :auth_token => token, :assignment => "Bidder: 2 B; Seller: 2 B", :sample_count => 20
        @profile = Scheduler.last.profiles.first
        @other_profile = Scheduler.last.profiles.last
        post "#{url}/remove_profile.json", :auth_token => token, :profile_id => @profile.id
        @scheduler.reload
      end
      
      it "should remove the profile from the scheduler" do
        @scheduler.profiles.count.should eql(1)
        @scheduler.required_samples(@profile).should eql(0)
      end
      
      it "should not remove the other profile" do
        @scheduler.required_samples(@other_profile).should eql(20)
      end
      
      it "should not destroy either profile" do
        Profile.find(@profile.id).should eql(@profile)
        Profile.find(@other_profile.id).should eql(@other_profile)
      end
    end
  end
   
  context "adding a new profile to an invalid scheduler" do
    let(:url) {"/api/v3/generic_schedulers/234"}
     
    it "should error out if the scheduler is invalid" do
      post "#{url}/add_profile.json", :auth_token => token, :assignment => "Bidder: 2 A; Seller: 2 B", :sample_count => 10
      Profile.where(:name => "Bidder: 2 A; Seller: 2 B").count.should == 0
      last_response.status.should eql(404)      
    end
  end
   
  context "adding an invalid profile" do
    let(:url) {"/api/v3/generic_schedulers/#{@scheduler.id}"}
  
    it "should not create a profile if the profile name is invalid" do
      post "#{url}/add_profile.json", :auth_token => token, :assignment => "Bidder: 1 A1 C; Seller: 2 B", :sample_count => 10
      Profile.count.should == 0
      last_response.status.should eql(422)
    end
  end
end