class ObservationValidator
  def validate_all(profile, location, files)
    validated_files = []
    files.each do |file|
      validated_files << validate(profile, location+"/"+file)
    end
    validated_files.compact
  end

  def validate(profile, file_name)
    begin
      json = Oj.load_file(file_name, mode: :compat)
      json['players'].each do |player|
        return nil if payoff_invalid(player)
      end
      return_hash = { features: numeralize(profile.simulator_instance, json['features']), observation_symmetry_groups: [] }
      profile.symmetry_groups.each do |symmetry_group|
        players = json['players'].select{ |player| player['role'] == symmetry_group.role && player['strategy'] == symmetry_group.strategy }
        return nil if players.count != symmetry_group.count
        return_hash[:observation_symmetry_groups] << build_symmetry_group_hash(profile.simulator_instance, symmetry_group, players)
      end
      return_hash
    rescue Oj::ParseError => e
      puts e.message
      nil
    end
  end

  private

  def build_symmetry_group_hash(simulator_instance, symmetry_group, players)
    players = clean_players(simulator_instance, players)
    payoffs = players.collect{ |player| player["p"] }
    { players: players, payoff: ArrayMath.average(payoffs.compact), payoff_sd: ArrayMath.std_dev(payoffs.compact) }
  end

  def numeralize(simulator_instance, hash)
    return {} if !hash
    return_hash = {}
    hash.each do |key, value|
      return_hash[simulator_instance.get_storage_key(key)] = ( value.numeric? ? value.to_f : ( value.is_a?(Hash) ? numeralize(simulator_instance, value) : value ) )
    end
    return_hash
  end

  def payoff_invalid(player)
    player['payoff'] != nil && (!player['payoff'].numeric? || player['payoff'].to_s == 'Inf')
  end

  def clean_players(simulator_instance, players)
    players.collect do |player|
      player_hash = numeralize(simulator_instance, player['features']).merge("p" => player['payoff']? player['payoff'].to_f : player['payoff'] )
    end
  end
end