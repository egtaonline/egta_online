require 'spec_helper'

describe Account do
  describe "validations" do
    context "account that can't login" do
      let!(:account){ Fabricate.build(:account_with_ssh_failure) }
      it "should add an error to username" do
        account.should have(1).error_on(:username)
        account.errors[:username].should include("Cannot authenticate on nyx as \'fakename\' with provided password.")
      end
    end
  end
end