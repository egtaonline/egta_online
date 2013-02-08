require "#{Rails.root}/lib/backend/backend"

Backend.configure do |config|
  config.queue_periodicity = 5.minutes
  config.queue_quantity = 30
  config.backend_implementation.flux_active_limit = 60
  config.backend_implementation.simulations_path = "/mnt/nfs/home/egtaonline/simulations"
  config.backend_implementation.flux_simulations_path = "/nfs/wellman_ls/egtaonline/simulations"
  config.backend_implementation.simulators_path = "/home/wellmangroup/many-agent-simulations"
  config.queue_max = 999
  if (Rails.env.production? && !(File.basename( $0 ) == "rake" && (ARGV == ["db:migrate"] || ARGV.last == "assets:precompile")))
    config.backend_implementation.setup_connections
  end
end