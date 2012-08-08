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
  
  def self.prepare_simulator(simulator)
    backend_implementation.prepare_simulator(simulator) 
  end
  
  def self.prepare_simulation(simulation, directory="#{Rails.root}/tmp/simulations")
    backend_implementation.prepare_simulation(simulation, directory)
  end

  def self.schedule_simulation(simulation)
    backend_implementation.schedule_simulation(simulation)
  end

  def self.update_simulation(simulation)
    backend_implementation.update_simulation(simulation)    
  end

  class Configuration
    attr_accessor :backend_implementation, :queue_periodicity, :queue_quantity

    def initialize
      @backend_implementation = FluxBackend.new
      @queue_periodicity = 5.minutes
      @queue_quantity = 30
    end
  end
  
  private
  
  def self.backend_implementation
    self.configuration.backend_implementation
  end
end