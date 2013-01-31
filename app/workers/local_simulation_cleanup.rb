class LocalSimulationCleanup
  include Sidekiq::Worker
  sidekiq_options queue: 'high_concurrency'

  def perform(simulation_number, location="#{Rails.root}/tmp/data")
    FileUtils.rm_rf("#{location}/#{simulation_number}")
  end
end