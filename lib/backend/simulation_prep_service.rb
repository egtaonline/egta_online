class SimulationPrepService
  def initialize(directory="#{Rails.root}/tmp/simulations")
    @directory = directory
  end

  def cleanup
    FileUtils.rm_rf(Dir["#{@directory}/*"])
  end

  def prepare_simulation(simulation)
    create_folder(simulation)
    generate_spec(simulation)
    Backend.prepare_simulation(simulation, @directory)
  end

  private

  def create_folder(simulation)
    FileUtils.mkdir("#{@directory}/#{simulation.id}")
  end

  def generate_spec(simulation)
    SpecGenerator.generate(simulation, @directory)
  end
end