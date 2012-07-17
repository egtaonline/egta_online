require "#{Rails.root}/lib/backend/backend"

Backend.configure do |config|
  config.queue_periodicity = 5.minutes
  config.queue_quantity = 30
  config.backend_implementation.flux_active_limit = 120
  if !Rails.env.test?
    config.backend_implementation.setup_connections
  end
end