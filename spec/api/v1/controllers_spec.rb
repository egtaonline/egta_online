require 'spec_helper'

describe "Controllers", :type => :api do
  let(:user) { Fabricate(:user) }
  let(:token) { user.authentication_token }
  
  shared_examples "a json enabled controller on index" do
    context "GET /api/v1/#{described_class.to_s.tableize}.json" do
      before do
        2.times {Fabricate(described_class.to_s.tableize.singularize.to_sym)}
      end
      it "should return the collection" do
        get "/api/v1/#{described_class.to_s.tableize}.json", :auth_token => token
        objects = described_class.all.to_json
        last_response.body.should eql(objects)
        last_response.status.should eql(200)
      end
    end
  end
  
  shared_examples "a json enabled controller on show" do
    context "GET /api/v1/#{described_class.to_s.tableize}/:id.json" do
      before do
        @object = Fabricate(described_class.to_s.tableize.singularize.to_sym)
      end
      it "should return the relevant object" do
        get "/api/v1/#{described_class.to_s.tableize}/#{@object.id}.json", :auth_token => token
        object_json = @object.to_json
        last_response.body.should eql(object_json)
        last_response.status.should eql(200)
      end
    end
  end
  
  describe Game do
    # it_behaves_like "a json enabled controller on index"
    it_behaves_like "a json enabled controller on show"
  end
  
  describe GenericScheduler do
    it_behaves_like "a json enabled controller on index"
    it_behaves_like "a json enabled controller on show"
  end
  
  describe Profile do
    it_behaves_like "a json enabled controller on show"
  end
end