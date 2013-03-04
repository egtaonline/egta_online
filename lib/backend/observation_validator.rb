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
      return_hash = { features: numeralize(json['features']), symmetry_groups: [] }
      profile.symmetry_groups.each do |symmetry_group|
        players = json['players'].select{ |player| player['role'] == symmetry_group.role && player['strategy'] == symmetry_group.strategy }
        return nil if players.count != symmetry_group.count
        return_hash[:symmetry_groups] << build_symmetry_group_hash(symmetry_group, players)
      end
      return_hash
    rescue Oj::ParseError => e
      puts e.message
      nil
    end
  end

  private

  def build_symmetry_group_hash(symmetry_group, players)
    players = clean_players(players)
    payoffs = players.collect{ |player| player[:payoff] }
    { count: symmetry_group.count, players: players,
      role: symmetry_group.role, strategy: symmetry_group.strategy,
      payoff: ArrayMath.average(payoffs), payoff_sd: ArrayMath.std_dev(payoffs) }
  end

  def numeralize(hash)
    return {} if !hash
    return_hash = {}
    hash.each do |key, value|
      return_hash[key] = ( value.numeric? ? value.to_f : ( value.is_a?(Hash) ? numeralize(value) : value ) )
    end
    return_hash
  end

  def payoff_invalid(player)
    !player['payoff'].numeric? || player['payoff'].to_s == 'NaN' || player['payoff'].to_s == 'Inf'
  end

  def clean_players(players)
    players.collect do |player|
      { payoff: player['payoff'].to_f, features: numeralize(player['features'])}
    end
  end
end