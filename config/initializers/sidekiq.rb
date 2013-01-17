Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Kiqstand::Middleware
    chain.remove Sidekiq::Middleware::Server::RetryJobs
  end
end