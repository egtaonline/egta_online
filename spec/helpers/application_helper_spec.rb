require 'spec_helper'

describe ApplicationHelper do
  describe "#page_title" do
    describe "with the new symbol" do
      it "should create the new page title" do
        page_title(:new, "account").should == 'New Account'
      end
    end
    describe "with the show symbol" do
      it "should create the show page title" do
        page_title(:show, "account").should == 'Account Information'
      end
    end
    describe "with the index symbol" do
      it "should create the index page title" do
        page_title(:index, "account").should == 'Accounts'
      end
    end
    describe "with the edit symbol" do
      it "should create the edit page title" do
        page_title(:edit, "account").should == 'Edit Account'
      end
    end
  end
end