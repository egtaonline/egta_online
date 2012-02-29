require 'spec_helper'

describe "HierarchicalSchedulers" do
  before(:each) do
    ResqueSpec.reset!
    user = Fabricate(:user)
    visit "/"
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    click_button 'Sign in'
  end

  describe "GET /hierarchical_schedulers" do
    pending
  end

  describe "POST /hierarchical_schedulers" do
    pending
  end

  describe "GET /hierarchical_schedulers/new" do
    pending
  end

  describe "GET /hierarchical_schedulers/:id/edit" do
    pending
  end

  describe "GET /hierarchical_schedulers/:id" do
    pending
  end

  describe "PUT /hierarchical_schedulers/:id" do
    pending
  end

  describe "DELETE /hierarchical_schedulers/:id" do
    pending
  end

  describe "POST /hierarchical_schedulers/:id/add_role" do
    pending
  end
  
  describe "POST /hierarchical_schedulers/:id/remove_role" do
    pending
  end

  describe "POST /hierarchical_schedulers/:id/add_strategy" do
    pending
  end
  
  describe "POST /hierarchical_schedulers/:id/remove_strategy" do
    pending
  end
  
  describe "POST /hierarchical_schedulers/update_parameters" do
    pending
  end
end