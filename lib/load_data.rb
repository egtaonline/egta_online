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

  def load_folder(folder_number, location)
    if Simulation.where(:serial_id => folder_number).count == 0
      entries = Dir.entries("#{location}/#{folder_number}") - [".", ".."]
      if entries.include?("payoff_data")
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
        size = yaml_load[0].size
        hash = yaml_load[1]
        hash[:size] = size
        hash[:parameters] = yaml_load[1].keys
        hash[:name] = yaml_load[1].to_s+size.to_s
        game = Game.find_or_create_by(hash)
        game.save!
        yaml_load[0].uniq.each{|strat| game.synchronous_add_strategy_from_name(strat)}
        profile = game.profiles.detect {|prof| prof.strategy_array == yaml_load[0].sort}
        simulation = Simulation.find_or_create_by(:serial_id => folder_number, :state => "complete", :profile_id => profile.id, :game_id => game.id, :size => payoff.size)
        simulation.save!
        simulation.update_attributes(:serial_id => folder_number)
        proxy = ServerProxy.new("localhost", location)
        if simulation.samples.count == 0
          proxy.gather_samples(simulation)
        end
        if game.features == nil or game.features == [] or game.features.first.feature_samples.where(:sample_id => simulation.samples.first.id).count == 0
          proxy.gather_features(simulation)
        end
      end
    end
  end
end