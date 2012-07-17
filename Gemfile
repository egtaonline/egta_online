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
gem 'bson_ext'
gem 'mongoid'

gem "state_machine"
gem "devise", '~> 1.5'
gem "yettings"
gem "foreman"
gem "net-ssh", github: 'egtaonline/net-ssh', :require => 'net/ssh'
gem "net-scp", :require => 'net/scp'
gem "kaminari"
gem "decent_exposure"
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem "simple_form"
gem "show_for", :git => "git://github.com/plataformatec/show_for.git" 
gem "passenger"
gem 'mongoid_rails_migrations', '0.0.14'
gem 'high_voltage'
gem "capistrano"
gem 'validates_email_format_of'
gem 'draper'
gem 'oj'

# Math
gem 'statsample'
gem 'statsample-optimization'

group :development do
  gem 'rvm-capistrano'
  gem 'thin'
  gem 'quiet_assets'
end

group :test, :development do
  gem 'gsl', :github => 'romanbsd/rb-gsl'
  gem "rspec-rails"
  gem 'debugger'
end

group :test do
  gem 'simplecov', :require => false
  gem "capybara"
  gem "rb-fsevent"
  gem "capybara-webkit"
  gem "growl"
  gem "spork", '~> 1.0rc'
  gem "cucumber-rails"
  gem "capybara-screenshot"
  gem "fabrication"
  gem "guard-rspec"
  gem "guard-cucumber"
  gem "guard-spork"
  gem "resque_spec"
  gem "mongoid-rspec"
end