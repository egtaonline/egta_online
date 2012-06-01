require 'resque_scheduler'
require 'resque_scheduler/server'

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
ENV['RAILS_ENV'] = Rails.env
rails_env = ENV['RAILS_ENV'] || 'production'
Resque.redis = resque_config[rails_env]
Resque.schedule = YAML.load_file("#{Rails.root}/config/resque_schedule.yml")

unless defined?(RESQUE_LOGGER)
  RESQUE_LOGGER = ActiveSupport::BufferedLogger.new("#{Rails.root}/log/resque.log")
  RESQUE_LOGGER.auto_flushing = true
end

require 'resque/failure/multiple'
require 'resque/failure/airbrake'
require 'resque/failure/redis'
Resque::Failure::Airbrake.configure do |config|
  config.api_key = '860cc72b7fb01397170a67a7997a7322'
end
Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Airbrake]
Resque::Failure.backend = Resque::Failure::Multiple