require 'spec_helper'

describe "Home" do
  before(:each) do
    @user = User.make!
  end

  describe "GET /" do
    it "redirects to login if user is not logged in" do
      visit "/"
      save_and_open_page
      page.should have_content("You need to sign in or sign up before continuing.")
    end

    it "shows the page if user is logged in" do
      login
      get "/home_index"
      save_and_open_page
      response.status.should be(200)
    end
  end

  def login
    visit "/users/sign_in"
    fill_in "Email", :with => @user.email
    fill_in "Password", :with => @user.password
    click_button "Sign in"
  end
end