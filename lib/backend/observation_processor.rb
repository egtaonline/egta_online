class ObservationProcessor
  def self.process_file(file_name, simulation)
    file = file_name.split('/').last
    if !simulation.files.include?(file)
      profile = simulation.profile
      from_json = ObservationValidator.validate(file_name, profile.assignment)
      if from_json
        from_json['players'].each do |player|
          player['features'].each { |key, value| player['features'][key] = value.to_f if value.is_a? BigDecimal }
          profile.create_player(player['role'], player['strategy'], player['payoff'], player['features'])
        end
        from_json['features'].each { |key, value| from_json['features'][key] = value.to_f if value.is_a? BigDecimal}
        profile.features_observations.create(features: from_json['features'])
        profile.inc(:sample_count, 1)
        simulation.push(:files, file)
      else
        simulation.update_attribute(:error_message, simulation.error_message + "#{file_name} was malformed or didn't match the expected profile assignment.\n")
      end
    end
  end
end