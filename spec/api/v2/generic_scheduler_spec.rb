require 'spec_helper'

describe "/api/v2/generic_schedulers", :type => :api do
  let(:user) { Fabricate(:user) }
  let(:token) { user.authentication_token }
  before do
    @scheduler = Fabricate(:generic_scheduler)
  end
  
  let(:url) {"/api/v2/generic_schedulers"}
  
  context "creating a scheduler" do
    context "successful creation" do
      it "successful JSON" do
        simulator = Simulator.last
        post "#{url}.json", :auth_token => token, :scheduler => {:simulator_id => simulator.id, :name => "test",
                                                            :active => true, :process_memory => 1000,
                                                            :time_per_sample => 120, :samples_per_simulation => 30,
                                                            :max_samples => 30, :parameter_hash => simulator.parameter_hash,
                                                            :nodes => 1}
        scheduler = GenericScheduler.last
        scheduler.simulator.should == simulator
        route = "/api/v2/generic_schedulers/#{scheduler.id}"
        last_response.status.should eql(201)
        last_response.headers["Location"].should eql(route)
        last_response.body.should eql(scheduler.to_json)
      end
    end
    
    context "unsuccessful creation" do
      it "unsuccessful JSON" do
        simulator = Simulator.last
        post "#{url}.json", :auth_token => token, :scheduler => {:simulator_id => simulator.id, :name => "test",
                                                          :active => true,
                                                          :time_per_sample => 120, :samples_per_simulation => 30,
                                                          :max_samples => 30, :parameter_hash => simulator.parameter_hash,
                                                          :nodes => 1}
        last_response.status.should eql(422)
        errors = {"errors" => {"process_memory" => ["can't be blank","is not a number"]}}.to_json
        last_response.body.should eql(errors)
      end
      
      it "invalid request" do
        simulator = Simulator.last
        post "#{url}.json", :auth_token => token
        last_response.status.should eql(422)
        errors = {"errors" => {"process_memory"=>["can't be blank","is not a number"],"name"=>["can't be blank"],"time_per_sample"=>["can't be blank","is not a number"],"samples_per_simulation"=>["can't be blank","is not a number"]}}.to_json
        last_response.body.should eql(errors)
      end
    end
  end

   context "update" do
     let(:url) {"/api/v2/generic_schedulers/#{@scheduler.id}"}
     
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
     let(:url) {"/api/v2/generic_schedulers/#{@scheduler.id}"}
     
     it "JSON" do
       delete "#{url}.json", :auth_token => token
       Scheduler.where(:id => @scheduler.id).count.should == 0
       last_response.status.should eql(204)
     end
   end
   
  context "adding a new profile" do
    let(:url) {"/api/v2/generic_schedulers/#{@scheduler.id}"}
     
    it "should create a profile if the profile name is valid" do
      post "#{url}/add_profile.json", :auth_token => token, :profile_name => "Bidder: 2 A; Seller: 2 B", :sample_count => 10
      Profile.where(:name => "Bidder: 2 A; Seller: 2 B").count.should == 1
    end
    it "should only add the profile once, even if you invoke it multiple times" do
      post "#{url}/add_profile.json", :auth_token => token, :profile_name => "Bidder: 2 A; Seller: 2 B", :sample_count => 10
      post "#{url}/add_profile.json", :auth_token => token, :profile_name => "Bidder: 2 A; Seller: 2 B", :sample_count => 10
      Profile.where(:name => "Bidder: 2 A; Seller: 2 B").count.should eql(1)
      Scheduler.last.profiles.count.should eql(1)
    end
  end
   
   context "adding a new profile to an invalid scheduler" do
     let(:url) {"/api/v2/generic_schedulers/234"}
     
     it "should error out if the scheduler is invalid" do
       post "#{url}/add_profile.json", :auth_token => token, :profile_name => "Bidder: 2 A; Seller: 2 B", :sample_count => 10
       Profile.where(:name => "Bidder: 2 A; Seller: 2 B").count.should == 0
       last_response.status.should eql(404)      
     end
   end
   
   context "adding an invalid profile" do
     let(:url) {"/api/v2/generic_schedulers/#{@scheduler.id}"}

     it "should not create a profile if the profile name is invalid" do
       post "#{url}/add_profile.json", :auth_token => token, :profile_name => "Bidder: 1 A1 C; Seller: 2 B", :sample_count => 10
       Profile.count.should == 0
       last_response.status.should eql(422)
     end
   end
end