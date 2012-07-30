require 'spec_helper'

describe Simulator, :type => :api do
  let(:user) { Fabricate(:user) }
  let(:token) { user.authentication_token }
  let(:simulator){Fabricate(:simulator)}
  let(:url) {"/api/v3/simulators/#{simulator.id}"}
  
  context "adding a new role" do
    it "should add the role to the simulator" do
      post "#{url}/add_role.json", :auth_token => token, :role => "Bidder"
      last_response.status.should eql(201)
      simulator.reload.roles.count.should eql(1)
      simulator.roles.first.name.should eql("Bidder")
    end
    
    it "should not add the role again if it already exists" do
      simulator.add_role("Bidder")
      post "#{url}/add_role.json", :auth_token => token, :role => "Bidder"
      last_response.status.should eql(304)
      simulator.reload.roles.count.should eql(1)
      simulator.roles.first.name.should eql("Bidder")
    end
    
    it "should notify you if the simulator does not exist" do
      post "/api/v3/simulators/1234/add_role.json", :auth_token => token, :role => "Bidder"
      last_response.status.should eql(404)
    end

    it "should notify you if role is missing" do
      post "#{url}/add_role.json", :auth_token => token
      last_response.status.should eql(422)
      last_response.body.should eql({:error => "you did not specify a role"}.to_json)
    end
  end
  
  context "adding a new strategy" do
    it "should add the strategy to the simulator" do
      post "#{url}/add_role.json", :auth_token => token, :role => "Bidder"
      post "#{url}/add_strategy.json", :auth_token => token, :role => "Bidder", :strategy => "Strat1"
      last_response.status.should eql(201)
      simulator.reload.roles.first.strategies.count.should eql(1)
      simulator.roles.first.strategies.first.should eql("Strat1")
    end
    
    it "should not add the strategy again if it already exists" do
      simulator.add_strategy("Bidder", "Strat1")
      post "#{url}/add_strategy.json", :auth_token => token, :role => "Bidder", :strategy => "Strat1"
      last_response.status.should eql(304)
      simulator.reload.roles.first.strategies.count.should eql(1)
      simulator.roles.first.strategies.first.should eql("Strat1")
    end
    
    it "should notify you if role is missing" do
      post "#{url}/add_strategy.json", :auth_token => token, :strategy => "Strat1"
      last_response.body.should eql({:error => "you did not specify a role"}.to_json)
      last_response.status.should eql(422)
    end
    
    it "should notify you if strategy is missing" do
      post "#{url}/add_strategy.json", :auth_token => token, :role => "Bidder"
      last_response.body.should eql({:error => "you did not specify a strategy"}.to_json)
      last_response.status.should eql(422)
    end
  end

  context "removing a role" do
    it "should notify you if role is missing" do
      post "#{url}/remove_role.json", :auth_token => token
      last_response.status.should eql(422)
      last_response.body.should eql({:error => "you did not specify a role"}.to_json)
    end
    
    context "the role does not exist" do
      it "informs the user of this" do
        post "#{url}/remove_role.json", :auth_token => token, :role => "All"
        last_response.status.should eql(204)
      end
    end
    
    context "the role exists" do
      before do
        simulator.add_role("All")
      end
      it "removes the role" do
        post "#{url}/remove_role.json", :auth_token => token, :role => "All"
        last_response.status.should eql(202)
        simulator.reload.roles.count.should == 0
      end
    end
  end
  
  context "removing a strategy" do
    it "should notify you if role is missing" do
      post "#{url}/remove_strategy.json", :auth_token => token, :strategy => "Strat1"
      last_response.body.should eql({:error => "you did not specify a role"}.to_json)
      last_response.status.should eql(422)
    end
    
    it "should notify you if strategy is missing" do
      post "#{url}/remove_strategy.json", :auth_token => token, :role => "Bidder"
      last_response.body.should eql({:error => "you did not specify a strategy"}.to_json)
      last_response.status.should eql(422)
    end
    
    context "the role does not exist" do
      it "informs the user of this" do
        post "#{url}/remove_strategy.json", :auth_token => token, :role => "All", :strategy => "Strat1"
        last_response.status.should eql(404)
      end
    end
    
    context "the role exists" do
      before do
        simulator.add_role("All")
      end
      it "removes the role" do
        post "#{url}/remove_role.json", :auth_token => token, :role => "All"
        last_response.status.should eql(202)
        simulator.reload.roles.count.should == 0
      end
    end
  end
end