require 'spec_helper'

describe "Strategy adding", :type => :api do
  let(:user) { Fabricate(:user) }
  let(:token) { user.authentication_token }
  
  shared_examples "a role manipulator" do
    let(:url) {"/api/v2/#{described_class.to_s.tableize}/#{role_manipulator.id}"}
    
    context "adding a new role" do
      it "should add the role to the #{described_class.to_s.tableize.singularize}" do
        post "#{url}/add_role.json", role_hash
        last_response.status.should eql(201)
        role_manipulator.reload.roles.count.should eql(1)
        role_manipulator.roles.first.name.should eql("Bidder")
      end
    
      it "should not add the role again if it already exists" do
        role_manipulator.add_role("Bidder")
        post "#{url}/add_role.json", role_hash
        last_response.status.should eql(304)
        role_manipulator.reload.roles.count.should eql(1)
        role_manipulator.roles.first.name.should eql("Bidder")
      end
    
      it "should notify you if the #{described_class.to_s.tableize.singularize} does not exist" do
        post "/api/v2/#{described_class.to_s.tableize}/1234/add_role.json", role_hash
        last_response.status.should eql(404)
      end

      it "should notify you if role is missing" do
        post "#{url}/add_role.json", :auth_token => token
        last_response.status.should eql(422)
        last_response.body.should eql({:error => "you did not specify a role"}.to_json)
      end
    end
  
    context "adding a new strategy" do
      it "should add the strategy to the #{described_class.to_s.tableize.singularize}" do
        post "#{url}/add_role.json", role_hash
        post "#{url}/add_strategy.json", :auth_token => token, :role => "Bidder", :strategy => "Strat1"
        last_response.status.should eql(201)
        role_manipulator.reload.roles.first.strategies.count.should eql(1)
        role_manipulator.roles.first.strategies.first.name.should eql("Strat1")
      end
    
      it "should not add the strategy again if it already exists" do
        role_manipulator.add_strategy("Bidder", "Strat1")
        post "#{url}/add_strategy.json", :auth_token => token, :role => "Bidder", :strategy => "Strat1"
        last_response.status.should eql(304)
        role_manipulator.reload.roles.first.strategies.count.should eql(1)
        role_manipulator.roles.first.strategies.first.name.should eql("Strat1")
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
          role_manipulator.add_role("All", 2)
        end
        it "removes the role" do
          post "#{url}/remove_role.json", :auth_token => token, :role => "All"
          last_response.status.should eql(202)
          role_manipulator.reload.roles.count.should == 0
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
          role_manipulator.add_role("All", 2)
        end
        it "removes the role" do
          post "#{url}/remove_role.json", :auth_token => token, :role => "All"
          last_response.status.should eql(202)
          role_manipulator.reload.roles.count.should == 0
        end
      end
    end
  end
  
  describe Simulator do
    let(:role_manipulator) {Fabricate(:simulator)}
    let(:role_hash) {{:auth_token => token, :role => "Bidder"}}
    it_behaves_like "a role manipulator"
  end
  
  describe Game do
    let(:role_manipulator) {Fabricate(:game)}
    let(:role_hash) {{:auth_token => token, :role => "Bidder", :count => 2}}
    it_behaves_like "a role manipulator"
    
    context "adding a new role" do
      it "should notify you if role is missing" do
        post "/api/v2/games/#{role_manipulator.id}/add_role.json", :auth_token => token, :role => "Bidder"
        last_response.status.should eql(422)
        last_response.body.should eql({:error => "you did not specify a count for this role"}.to_json)
      end
    end
  end
end