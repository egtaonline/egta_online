rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
Resque.redis = resque_config[rails_env]


require 'resque_scheduler'
Resque.schedule = YAML.load_file("#{Rails.root}/config/resque_schedule.yml")

unless defined?(RESQUE_LOGGER)
  RESQUE_LOGGER =
ActiveSupport::BufferedLogger.new("#{Rails.root}/log/resque.log")
  RESQUE_LOGGER.auto_flushing = true
end
Resque::NYX_PROXY = ServerProxy.new
Resque::NYX_PROXY.start
