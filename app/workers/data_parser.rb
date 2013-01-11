class DataParser
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(number, location="#{Rails.root}/tmp/data/#{number}")
    simulation = Simulation.find(number)
    if simulation.state != 'complete'
      files = Dir.entries(location).keep_if{ |name| name =~ /\A(.*)observation(.)*.json\z/ }
      processor = ObservationProcessor.new(location)
      processor.process_files(simulation, files)
    end
  end
end