require 'spec_helper'

describe "/api/v1/generic_schedulers", :type => :api do
  let(:user) { Fabricate(:user) }
  let(:token) { user.authentication_token }
  before do
    @scheduler = Fabricate(:generic_scheduler)
  end
  
  let(:url) {"/api/v1/generic_schedulers"}
  
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
        route = "/api/v1/generic_schedulers/#{scheduler.id}"
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
        errors = {"process_memory" => ["can't be blank","is not a number"]}.to_json
        last_response.body.should eql(errors)
      end
      
      it "invalid request" do
        simulator = Simulator.last
        post "#{url}.json", :auth_token => token
        last_response.status.should eql(422)
        errors = {"process_memory"=>["can't be blank","is not a number"],"name"=>["can't be blank"],"time_per_sample"=>["can't be blank","is not a number"],"samples_per_simulation"=>["can't be blank","is not a number"],"max_samples"=>["can't be blank","is not a number"]}.to_json
        last_response.body.should eql(errors)
      end
    end
  end

   # context "find" do
   #   it "JSON search" do
   #     get "#{url}/find.json", :auth_token => token, :criteria => {:name => "generic"}
   #     last_response.body.should eql([@scheduler].to_json)
   #     last_response.status.should eql(200)
   #   end
   #   
   #   it "unsuccessful search" do
   #     get "#{url}/find.json", :auth_token => token, :criteria => {:name => "e"}
   #     last_response.body.should eql([].to_json)
   #     last_response.status.should eql(200)
   #   end
   # end
   # 
   # context "update" do
   #   let(:url) {"/api/v1/generic_schedulers/#{@scheduler.id}"}
   #   
   #   it "successful JSON" do
   #     put "#{url}.json", :auth_token => token, :scheduler => {:max_samples => 60}
   #     last_response.status.should eql(200)
   #     @scheduler.reload
   #     @scheduler.max_samples.should eql(60)
   #     last_response.body.should eql("{}")
   #   end
   #   
   #   it "unsuccessful JSON" do
   #     put "#{url}.json", :auth_token => token, :scheduler => {:max_samples => ""}
   #     last_response.status.should eql(422)
   #     @scheduler.reload
   #     @scheduler.max_samples.should eql(10)
   #     errors = {:max_samples => ["can't be blank","is not a number"]}.to_json
   #     last_response.body.should eql(errors)
   #   end
   # end
   # 
   # context "destroy" do
   #   let(:url) {"/api/v1/generic_schedulers/#{@scheduler.id}"}
   #   
   #   it "JSON" do
   #     delete "#{url}.json", :auth_token => token
   #     Scheduler.where(:id => @scheduler.id).count.should == 0
   #     last_response.status.should eql(200)
   #   end
   # end
   # 
   context "adding a new profile" do
     let(:url) {"/api/v1/generic_schedulers/#{@scheduler.id}"}
     
     before do
       Fabricate(:strategy, :name => "A", :number => 1)
       Fabricate(:strategy, :name => "B", :number => 2)
     end
     it "should create a profile if the profile name is valid" do
       post "#{url}/add_profile.json", :auth_token => token, :profile_name => "Bidder: A, A; Seller: B, B"
       Profile.where(:proto_string => "Bidder: 1, 1; Seller: 2, 2").count.should == 1
     end
   end
   
   context "adding a new profile to an invalid scheduler" do
     let(:url) {"/api/v1/generic_schedulers/234"}
     
     before do
       Fabricate(:strategy, :name => "A", :number => 1)
       Fabricate(:strategy, :name => "B", :number => 2)
     end
     it "should error out if the scheduler is invalid" do
       post "#{url}/add_profile.json", :auth_token => token, :profile_name => "Bidder: A, A; Seller: B, B"
       Profile.where(:proto_string => "Bidder: 1, 1; Seller: 2, 2").count.should == 0
       last_response.status.should eql(404)      
     end
   end
   
   context "adding an invalid profile" do
     let(:url) {"/api/v1/generic_schedulers/#{@scheduler.id}"}
     
     before do
       Fabricate(:strategy, :name => "A", :number => 1)
       Fabricate(:strategy, :name => "B", :number => 2)
     end
     it "should not create a profile if the profile name is invalid" do
       post "#{url}/add_profile.json", :auth_token => token, :profile_name => "Bidder: A, C; Seller: B, B"
       Profile.count.should == 0
       last_response.status.should eql(422)
     end
   end
end