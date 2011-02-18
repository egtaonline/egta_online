require 'spec_helper'

describe Account do
  describe "#validate_login" do
    it "should fail to save when unable to connect" do
      @account = Account.make_unsaved(:username => "intruder", :host => "nyx-login.engin.umich.edu")
      @account.should_not be_valid
      @account = Account.make_unsaved(:username => "bcassell", :host => "intruder")
      @account.should_not be_valid
    end

    it "should succeed at saving when it can connect" do
      @account =  Account.make_unsaved(:username => "bcassell", :host => "nyx-login.engin.umich.edu")
      @account.should be_valid
    end
  end
end
