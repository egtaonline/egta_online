require 'spork'

Spork.prefork do
  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end
  
  ENV["RAILS_ENV"] ||= 'test'

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require "rails/mongoid"
  Spork.trap_class_method(Rails::Mongoid, :load_models)
  require 'capybara/rspec'
  require 'fabrication'
  require 'resque_spec/scheduler'
  Capybara.default_selector = :css
  Capybara.javascript_driver = :webkit
  
  RSpec.configure do |config|


    config.include Mongoid::Matchers
    config.before(:each) do
      Mongoid.default_session.collections.select {|c| c.name !~ /system/ }.each(&:drop)
    end
    
    config.before(:all) do
      Mongoid.default_session.collections.select {|c| c.name !~ /system/ }.each(&:drop)
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
  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end
  
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  Dir[Rails.root.join("app/workers/*")].each {|f| require f}
  Dir["#{Rails.root}/lib/util/*", "#{Rails.root}/lib/backend/*.rb", "#{Rails.root}/lib/backend/flux/*.rb"].each do |file|
    load file
  end
end