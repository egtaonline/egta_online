require 'spec_helper'

describe "Schedulers" do
  before(:each) do
    ResqueSpec.reset!
    user = Fabricate(:user)
    visit "/"
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    click_button 'Sign in'
  end

  describe "POST /schedulers/update_parameters" do
    pending
  end

  describe "GET /schedulers" do
    pending
  end

  describe "POST /schedulers" do
    pending
  end

  describe "GET /schedulers/new" do
    pending
  end

  describe "GET /schedulers/:id/edit" do
    pending
  end

  describe "GET /schedulers/:id" do
    pending
  end

  describe "PUT /schedulers/:id" do
    pending
  end

  describe "DELETE /schedulers/:id" do
    pending
  end
end