require 'spec_helper'

describe "Strategy adding", :type => :api do
  let(:user) { Fabricate(:user) }
  let(:token) { user.authentication_token }

  shared_examples "a role manipulator" do
    let(:url) {"/api/v3/#{described_class.to_s.tableize}/#{role_manipulator.id}"}

    context "adding a new role" do
      it "should add the role to the #{described_class.to_s.tableize.singularize}" do
        post "#{url}/add_role.json", role_hash
        response.status.should eql(201)
        role_manipulator.reload.roles.count.should eql(1)
        role_manipulator.roles.first.name.should eql("Bidder")
      end

      it "should do nothing if it already exists" do
        role_manipulator.add_role("Bidder")
        post "#{url}/add_role.json", role_hash
        response.status.should eql(201)
        role_manipulator.reload.roles.count.should eql(1)
        role_manipulator.roles.first.name.should eql("Bidder")
      end

      it "should notify you if the #{described_class.to_s.tableize.singularize} does not exist" do
        post "/api/v3/#{described_class.to_s.tableize}/1234/add_role.json", role_hash
        response.status.should eql(404)
      end

      it "should notify you if role is missing" do
        post "#{url}/add_role.json", :auth_token => token
        response.status.should eql(422)
        response.body.should eql({:error => "you did not specify a role"}.to_json)
      end
    end

    context "adding a new strategy" do
      it "should add the strategy to the #{described_class.to_s.tableize.singularize}" do
        post "#{url}/add_role.json", role_hash
        post "#{url}/add_strategy.json", :auth_token => token, :role => "Bidder", :strategy => "Strat1"
        response.status.should eql(201)
        role_manipulator.reload.roles.first.strategies.count.should eql(1)
        role_manipulator.roles.first.strategies.first.should eql("Strat1")
      end

      it "should do nothing if the strategy already exists" do
        role_manipulator.add_strategy("Bidder", "Strat1")
        post "#{url}/add_strategy.json", :auth_token => token, :role => "Bidder", :strategy => "Strat1"
        response.status.should eql(201)
        role_manipulator.reload.roles.first.strategies.count.should eql(1)
        role_manipulator.roles.first.strategies.first.should eql("Strat1")
      end

      it "should notify you if role is missing" do
        post "#{url}/add_strategy.json", :auth_token => token, :strategy => "Strat1"
        response.body.should eql({:error => "you did not specify a role"}.to_json)
        response.status.should eql(422)
      end

      it "should notify you if strategy is missing" do
        post "#{url}/add_strategy.json", :auth_token => token, :role => "Bidder"
        response.body.should eql({:error => "you did not specify a strategy"}.to_json)
        response.status.should eql(422)
      end
    end

    context "removing a role" do
      it "should notify you if role is missing" do
        post "#{url}/remove_role.json", :auth_token => token
        response.status.should eql(422)
        response.body.should eql({:error => "you did not specify a role"}.to_json)
      end

      context "the role does not exist" do
        it "does nothing" do
          role_manipulator.add_role("All", 2)
          post "#{url}/remove_role.json", :auth_token => token, :role => "None"
          response.status.should eql(201)
          role_manipulator.reload.roles.count.should == 1
        end
      end

      context "the role exists" do
        before do
          role_manipulator.add_role("All", 2)
        end
        it "removes the role" do
          post "#{url}/remove_role.json", :auth_token => token, :role => "All"
          response.status.should eql(201)
          role_manipulator.reload.roles.count.should == 0
        end
      end
    end

    context "removing a strategy" do
      it "should notify you if role is missing" do
        post "#{url}/remove_strategy.json", :auth_token => token, :strategy => "Strat1"
        response.body.should eql({:error => "you did not specify a role"}.to_json)
        response.status.should eql(422)
      end

      it "should notify you if strategy is missing" do
        post "#{url}/remove_strategy.json", :auth_token => token, :role => "Bidder"
        response.body.should eql({:error => "you did not specify a strategy"}.to_json)
        response.status.should eql(422)
      end

      context "the role does not exist" do
        it "does nothing" do
          role_manipulator.add_role("All", 2)
          role_manipulator.add_strategy("All", "Strat1")
          post "#{url}/remove_strategy.json", :auth_token => token, :role => "None", :strategy => "Strat1"
          response.status.should eql(201)
          role_manipulator.reload.roles.first.strategies.should == ["Strat1"]
        end
      end

      context "the role exists" do
        before do
          role_manipulator.add_role("All", 2)
        end
        it "removes the role" do
          post "#{url}/remove_role.json", :auth_token => token, :role => "All"
          response.status.should eql(201)
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
      it "should notify you if count is missing" do
        post "/api/v3/games/#{role_manipulator.id}/add_role.json", :auth_token => token, :role => "Bidder"
        response.status.should eql(422)
        response.body.should eql({:error => "you did not specify a count for this role"}.to_json)
      end
    end
  end
end