require "spec_helper"

describe InstructionsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/instructions" }.should route_to(:controller => "instructions", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/instructions/new" }.should route_to(:controller => "instructions", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/instructions/1" }.should route_to(:controller => "instructions", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/instructions/1/edit" }.should route_to(:controller => "instructions", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/instructions" }.should route_to(:controller => "instructions", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/instructions/1" }.should route_to(:controller => "instructions", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/instructions/1" }.should route_to(:controller => "instructions", :action => "destroy", :id => "1")
    end

  end
end
