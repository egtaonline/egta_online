require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require "rails/mongoid"
  Spork.trap_class_method(Rails::Mongoid, :load_models)
  require 'capybara/rspec'
  require 'fabrication'
  Capybara.default_selector = :css
  Capybara.javascript_driver = :webkit
  
  RSpec.configure do |config|

    config.before(:each) do
      Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
    end
    
    config.before(:each, :type => :request) do
      ResqueSpec.reset!
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

  end
end

Spork.each_run do
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  Dir[Rails.root.join("app/workers/*.rb")].each {|f| require f}
end