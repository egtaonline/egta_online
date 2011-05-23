require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require 'rails/mongoid'
  Spork.trap_class_method(Rails::Mongoid, :load_models)
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'

  RSpec.configure do |config|
    require "database_cleaner"

    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
    config.mock_with :rspec

  end
end

Spork.each_run do
  load File.expand_path("../../app/helpers/application_helper.rb", __FILE__)
  load File.expand_path("../../lib/data_parser.rb", __FILE__)
  load File.expand_path("../../lib/server_proxy.rb", __FILE__)
end
