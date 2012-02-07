require 'spec_helper'

describe Account do
  describe "validations" do
    context "account that can't login" do
      let!(:account){ Fabricate.build(:account_with_failure) }
      it "should add an error to username" do
        account.should have(1).error_on(:username)
        account.errors[:username].should include("Cannot authenticate on nyx as \'fakename\' with provided password.")
      end
    end
    
    context "account is missing group permissions" do
      it "should add errors about lack of group permission" do
        ssh = mock(Net::SSH)
        Net::SSH.stub(:start).and_yield(ssh)
        ssh.stub("exec!").with("echo #{KEY} >> ~/.ssh/authorized_keys").and_return("")
        ssh.stub("exec!").with("groups").and_return("")
        @account = Fabricate.build(:account_with_failure)
        @account.should have(1).error_on(:username)
        @account.errors[:username].should include("\'fakename\' is not a member of wellman group.  Ask Mike to add you.")
      end
    end
  end
  
  describe "saving" do
    it "should not save the provided password" do
      Fabricate(:account, :username => "fake", :password => "fake")
      Account.where(:username => "fake").first["password"].should eql(nil)
    end
  end
end