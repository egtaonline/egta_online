class ObservationProcessor
  def self.process_file(file_name, simulation)
    file = file_name.split('/').last
    if !simulation.files.include?(file)
      profile = simulation.profile
      from_json = ObservationValidator.validate(file_name, profile.assignment)
      if from_json
        player['features'].each { |key, value| player['features'][key] = value.to_f }
        from_json['players'].each do |player|
          profile.create_player(player['role'], player['strategy'], player['payoff'], player['features'])
        end
        from_json['features'].each do |key, value|
          profile.features_observations.create(name: key, observation: value)
        end
        profile.inc(:sample_count, 1)
        simulation.push(:files, file)
      else
        simulation.update_attribute(:error_message, simulation.error_message + "#{file_name} was malformed or didn't match the expected profile assignment.\n")
      end
    end
  end
end