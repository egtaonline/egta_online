source 'http://rubygems.org'

gem 'rails', '~> 3.2'

# Asset template engines
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'rack-perftools_profiler', :require => 'rack/perftools_profiler'
gem 'twitter-bootstrap-rails'
gem 'oj'
gem 'rdiscount'
gem "haml-rails"

# JS framework
gem 'jquery-rails'

# Background Processing
gem 'sidekiq', '~> 2.0'
gem 'sidekiq-failures'
gem 'kiqstand'
gem 'clockwork'
gem 'slim'
gem 'sinatra', :require => nil

# Error reporting
gem "airbrake"

gem 'celluloid'

# Database
gem 'mongoid'
gem 'mongoid_rails_migrations', :github => 'acechase/mongoid_rails_migrations'
gem 'mongoid-sequence', :github => 'cblock/mongoid-sequence'

gem "devise"
gem "kaminari"
gem "decent_exposure"
gem 'carrierwave-mongoid', require: 'carrierwave/mongoid'
gem "simple_form"
gem "show_for"
gem 'high_voltage'
gem 'puma', github: 'puma/puma'

group :production do
  gem "foreman"
end

group :development do
  gem 'quiet_assets'
  gem 'capistrano'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
end

group :test, :development do
  gem "rspec-rails"
end

group :test do
  gem 'simplecov', :require => false
  gem "capybara"
  gem "rb-fsevent"
  gem "poltergeist"
  gem "growl"
  gem "cucumber-rails"
  gem "capybara-screenshot"
  gem "fabrication"
  gem "guard-rspec"
  gem "guard-cucumber"
  gem "mongoid-rspec"
  gem "rspec-fire"
end