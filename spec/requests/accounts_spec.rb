require 'spec_helper'

describe "Accounts" do
  
  describe "GET /accounts" do
    it "displays accounts" do
      Fabricate.build(:account).save(:validate => false)
      visit accounts_path
      page.should have_content("bcassell")
      page.should have_content("Yes")
    end
  end
  
  describe "GET /accounts/new" do
    it "shows the new account page" do
      visit new_account_path
      page.should have_content("New Account")
      page.should have_content("Username")
      page.should have_content("Password")
    end
  end
  
  describe "GET /accounts/:id" do
    it "displays the relevant account" do
      account = Fabricate.build(:account)
      account.save(:validate => false)
      visit account_path(account.id)
      page.should have_content("bcassell")
      page.should have_content("Yes")
    end
  end
  
  describe "GET /accounts/:id/edit" do
    it "shows the edit account page" do
      account = Fabricate.build(:account)
      account.save(:validate => false)
      visit edit_account_path(account.id)
      page.should have_content("Edit Account")
      page.should have_content("Username")
      page.should have_content("Active")
    end
  end
  
  describe "POST /accounts" do
    it "creates an account" do
      
      # Mocking out the communication to nyx
      ssh = mock(Net::SSH)
      Net::SSH.stub(:start).and_yield(ssh)
      ssh.stub("exec!").with("echo #{KEY} >> ~/.ssh/authorized_keys").and_return("")
      ssh.stub("exec!").with("groups").and_return("wellman")
      
      visit new_account_path
      fill_in "Username", :with => "good_user"
      fill_in "Password", :with => "good_password"
      click_button "Create Account"
      page.should have_content("good_user")
      page.should_not have_content("Some errors were found")
    end
  end
  
  describe "PUT /accounts/:id/" do
    it "updates the relevant account" do
      account = Fabricate.build(:account)
      account.save(:validate => false)
      visit edit_account_path(account.id)
      uncheck "Active"
      click_button "Update Account"
      page.should have_content("bcassell")
      page.should have_content("No")
    end
  end
end