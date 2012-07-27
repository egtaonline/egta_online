class DataParser
  include Resque::Plugins::UniqueJob
  @queue = :nyx_actions

  def self.perform(number, location="#{Rails.root}/tmp/data/#{number}")
    simulation = Simulation.where(number: number).first
    if simulation != nil
      Dir.entries(location).keep_if{ |name| name =~ /\A(.*)observation(.)*.json\z/ }.each{ |file| ObservationProcessor.process_file("#{location}/#{file}", simulation) }
      simulation.files == [] ? simulation.failure! : simulation.finish!
    end
  end
end