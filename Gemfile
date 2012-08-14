source 'http://rubygems.org'

gem 'rails', '~> 3.2'

# Asset template engines
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'twitter-bootstrap-rails'
gem "haml-rails"
gem 'rdiscount'
gem 'rabl'
gem 'oj'

# JS framework
gem 'jquery-rails'

# Background Processing
gem 'resque', :require => 'resque/server'
gem 'resque-scheduler', :require => 'resque_scheduler'
gem "resque-loner"

# Error reporting
gem "airbrake"

# Database
gem 'mongoid'
gem 'mongoid-sequence', :github => 'cblock/mongoid-sequence'
gem "state_machine"
gem "devise"
gem "yettings"
gem "foreman"
gem "net-ssh", :require => 'net/ssh'
gem "net-scp", :require => 'net/scp'
gem "kaminari"
gem "decent_exposure"
gem 'carrierwave-mongoid', :github => "jnicklas/carrierwave-mongoid", :branch => 'mongoid-3.0', :require => 'carrierwave/mongoid'
gem "simple_form"
gem "show_for", :git => "git://github.com/plataformatec/show_for.git"
gem 'high_voltage'
gem "capistrano"
gem 'draper'

group :production do
  gem 'unicorn'
end

group :development do
  gem 'rack-perftools_profiler', :require => 'rack/perftools_profiler'
  gem 'rvm-capistrano'
  gem 'thin'
  gem 'quiet_assets'
end

group :test, :development do
  gem "rspec-rails"
  gem 'spork', '~> 1.0rc'
  gem 'debugger'
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