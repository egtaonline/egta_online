class DataLoader
  def load_db(location = "#{ROOT_PATH}/db")
    entries = Dir.entries(location) - [".", ".."]
    entries.each do |entry|
      if entry.to_i.to_s == entry
        puts entry
        load_folder(entry.to_i, location)
      end
    end
  end

  def load_simulator(name, version, location)
    @simulator = Simulator.where(:name => name, :version => version).first
    @simulator.games.each {|game| game.simulations.each {|sim| load_folder(sim.id, location)}}
  end

  def load_folder(folder_number, location)
    if Simulation.where(:id => folder_number).count > 0 && File.exists?("#{location}/#{folder_number}")
      simulation = Simulation.where(:id => folder_number).first
      simulation.samples.destroy_all
      entries = Dir.entries("#{location}/#{folder_number}") - [".", ".."]
      if entries.include?("payoff_data")
        game = simulation.game
        yaml_load = Array.new
        File.open("#{location}/#{folder_number}/simulation_spec.yaml") do |file|
          YAML.load_documents(file) do |y|
            yaml_load << y
          end
        end
        payoff = Array.new
        File.open("#{location}/#{folder_number}/payoff_data") do |file|
          YAML.load_documents(file) do |y|
            payoff << y
          end
        end
        proxy = ServerProxy.new("localhost", location)
        proxy.gather_samples(simulation, location)
        simulation.update_attributes(:state => 'complete')
        if game.features == nil or game.features == [] or game.features.first.feature_samples.where(:sample_id => simulation.samples.first.id).count == 0
          proxy.gather_features(simulation, location)
        end
      else
        simulation.update_attributes(:state => 'failed')
      end
    end
  end
end
