class DataParser
  include Sidekiq::Worker
  sidekiq_options unique: true, queue: 'high_concurrency'

  def perform(number, location="#{Backend.backend_implementation.simulations_path}/#{number}")
    simulation = Simulation.find(number)
    if simulation.state != 'complete'
      files = Dir.entries(location).keep_if{ |name| name =~ /\A(.*)observation(.)*.json\z/ }
      processor = ObservationProcessor.new(location)
      processor.process_files(simulation, files)
    end
  end
end