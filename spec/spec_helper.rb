require 'simplecov'
require 'unit_helper'

SimpleCov.start 'rails'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require "rails/mongoid"
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'fabrication'
require 'sidekiq/testing'
Capybara.default_selector = :css
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|

  config.include Mongoid::Matchers
  config.before(:each) do
    Mongoid.purge!
  end

  config.before(:all) do
    Mongoid.purge!
  end

  config.before(:each, :type => :request) do
    user = Fabricate(:user)
    visit "/"
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    click_button 'Sign in'
  end

  config.after(:each, :type => :request) do
    visit "/users/sign_out"
  end

  config.mock_with :rspec
  config.order = "random"
end