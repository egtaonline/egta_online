source 'http://rubygems.org'

gem 'rails'

# Asset template engines
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'twitter-bootstrap-rails'

gem 'jquery-rails'
gem 'resque', :require => 'resque/server', :git => 'git://github.com/defunkt/resque.git'
gem 'resque-scheduler'
gem "haml"
gem "haml-rails"
gem "airbrake"
gem "bson_ext", "~>1.5"
gem "mongoid"
gem "state_machine"
gem "devise"
gem "yettings"
gem "foreman"
gem "net-ssh", :require => ['net/ssh']
gem "net-ssh-multi", :require => ['net/ssh/multi']
gem "net-scp", :require => ['net/scp']
gem "kaminari"
gem "decent_exposure"
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem "simple_form"
gem "show_for", :git => "git://github.com/plataformatec/show_for.git" 
gem "passenger"
gem "resque-loner"
gem 'mongoid_rails_migrations', '0.0.14'
gem 'rabl'
gem 'high_voltage'
gem 'rdiscount'
gem "capistrano"

group :development do
  gem 'rvm-capistrano'
end

group :test, :development do
  gem "rspec-rails"
end

group :test do
  gem "capybara"
  gem "rb-fsevent"
  gem "capybara-webkit"
  gem "growl"
  gem "spork", '~> 1.0rc'
  gem "cucumber-rails"
  gem "capybara-screenshot"
  gem "database_cleaner"
  gem "fabrication"
  gem "guard-rspec"
  gem "guard-cucumber"
  gem "guard-spork"
  gem "resque_spec"
end
