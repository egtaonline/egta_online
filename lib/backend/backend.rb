require "#{Rails.root}/lib/backend/flux_backend"

module Backend
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.reset
    self.configuration ||= Configuration.new
  end
  
  def self.prepare_simulation(simulation)
    self.configuration.backend_implementation.prepare_simulation(simulation)
  end

  def self.schedule(simulation)
    self.configuration.backend_implementation.schedule(simulation)
  end

  class Configuration
    attr_accessor :backend_implementation, :queue_periodicity, :queue_quantity

    def initialize
      @backend_implementation = FluxBackend.new
      @queue_periodicity = 5.minutes
      @queue_quantity = 30
    end
  end
end