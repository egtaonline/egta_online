require 'spec_helper'

describe "BaseController", :type => :api do
  let(:user) { Fabricate(:user) }
  let(:token) { user.authentication_token }
  
  shared_examples "an API controller" do
    context "missing object" do
      let(:url){"/api/v3/#{described_class.to_s.tableize}/1234"}
      it "returns an appropriate 404" do
        get "#{url}.json", :auth_token => token
        response.status.should eql(404)
        response.body.should eql({:error => "the #{described_class.to_s.tableize.singularize} you were looking for could not be found"}.to_json)
      end
    end
  end
  
  describe GenericScheduler do
    it_behaves_like "an API controller"
  end
  
  describe Simulator do
    it_behaves_like "an API controller"
  end
  
  describe Game do
    it_behaves_like "an API controller"
  end
  
  describe Profile do
    it_behaves_like "an API controller"
  end
end