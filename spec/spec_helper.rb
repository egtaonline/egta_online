require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'
  require 'fabrication'

  RSpec.configure do |config|

    config.before(:each) do
      Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
    end

    config.mock_with :rspec

  end
end

Spork.each_run do
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
end