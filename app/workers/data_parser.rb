class DataParser
  include Resque::Plugins::UniqueJob
  @queue = :nyx_actions

  def self.perform(number, location="#{Rails.root}/tmp/data/")
    simulation = Simulation.where(number: number).first
    files = Dir.entries(location).keep_if{ |name| name =~ /\A(.*)observation(.)*.json\z/ }
    processor = ObservationProcessor.new(location)
    processor.process_files(simulation, files)
  end
end