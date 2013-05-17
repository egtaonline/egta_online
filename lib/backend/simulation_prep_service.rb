class SimulationPrepService
  def initialize(directory=Backend.backend_implementation.simulations_path)
    @directory = directory
  end

  def prepare_simulation(simulation)
    puts 'Create Folder'
    create_folder(simulation)
    puts 'Generate Spec'
    generate_spec(simulation)
    puts 'Prepare'
    Backend.prepare_simulation(simulation)
  end

  private

  def create_folder(simulation)
    FileUtils.rm_rf("#{@directory}/#{simulation.id}")
    FileUtils.mkdir("#{@directory}/#{simulation.id}")
  end

  def generate_spec(simulation)
    SpecGenerator.generate(simulation, @directory)
  end
end