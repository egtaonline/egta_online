require 'resque_scheduler'
Resque.schedule = YAML.load_file("#{Rails.root}/config/resque_schedule.yml")
Resque::NYX_PROXY = ServerProxy.new
Resque::NYX_PROXY.start