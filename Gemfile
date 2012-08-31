source 'http://rubygems.org'

gem 'rails', '~> 3.2'

# Asset template engines
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
platform :ruby do
  gem 'rack-perftools_profiler', :require => 'rack/perftools_profiler'
  gem 'twitter-bootstrap-rails'
  gem 'oj'
  gem 'rdiscount'
  gem 'thin'
end
gem "haml-rails"
gem 'rabl'

# JS framework
gem 'jquery-rails'

# Background Processing
gem 'resque', :require => 'resque/server'
gem 'resque-scheduler', :require => 'resque_scheduler'
gem "resque-loner"

# Error reporting
gem "airbrake"

gem 'celluloid'

# Database
gem 'mongoid'
gem 'mongoid_rails_migrations', :github => 'acechase/mongoid_rails_migrations'
gem 'mongoid-sequence', :github => 'cblock/mongoid-sequence'

gem "state_machine"
gem "devise"
gem "yettings"
gem "kaminari"
gem "decent_exposure"
gem 'carrierwave-mongoid', :github => "jnicklas/carrierwave-mongoid", :branch => 'mongoid-3.0', :require => 'carrierwave/mongoid'
gem "simple_form"
gem "show_for", :git => "git://github.com/plataformatec/show_for.git"
gem 'high_voltage'
gem "capistrano"

group :production do
  gem "foreman"
end

group :development do
  gem 'quiet_assets'
end

group :test, :development do
  gem "rspec-rails"
  gem 'spork', '~> 1.0rc'
end

group :test do
  gem 'simplecov', :require => false
  gem "capybara"
  gem "rb-fsevent"
  gem "capybara-webkit"
  gem "growl"
  gem "cucumber-rails"
  gem "capybara-screenshot"
  gem "fabrication"
  gem "guard-rspec"
  gem "guard-cucumber"
  gem "guard-spork"
  gem "resque_spec"
  gem "mongoid-rspec"
end