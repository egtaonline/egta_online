class SimulationPrepService
  def initialize(directory=Backend.backend_implementation.simulations_path)
    @directory = directory
  end

  def prepare_simulation(simulation)
    create_folder(simulation)
    generate_spec(simulation)
    Backend.prepare_simulation(simulation)
  end

  private

  def create_folder(simulation)
    FileUtils.mkdir("#{@directory}/#{simulation.id}")
  end

  def generate_spec(simulation)
    SpecGenerator.generate(simulation, @directory)
  end
end