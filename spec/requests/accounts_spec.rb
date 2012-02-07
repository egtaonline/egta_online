require 'spec_helper'

describe "Accounts" do
  before(:each) do
    user = Fabricate(:user)
    visit "/"
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    click_button 'Sign in'
  end

  describe "GET /accounts" do
    it "displays accounts" do
      Fabricate(:account)
      visit accounts_path
      page.should have_content("bcassell")
      page.should have_content("true")
    end
  end
  
  describe "GET /accounts/:id" do
    it "displays the relevant account" do
      account = Fabricate(:account)
      visit account_path(account.id)
      page.should have_content("bcassell")
      page.should have_content("true")
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
      account = Fabricate(:account)
      visit edit_account_path(account.id)
      uncheck "Active"
      click_button "Update Account"
      page.should have_content("bcassell")
      page.should have_content("false")
    end
  end
end