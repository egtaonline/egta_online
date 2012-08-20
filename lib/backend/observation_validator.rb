class ObservationValidator
  def self.validate_all(profile, location, files)
    validated_files = []
    files.each do |file|
      validated_files << validate(profile, location+"/"+file)
    end
    validated_files.compact
  end

  def self.validate(profile, file_name)
    begin
      json = Oj.load_file(file_name, mode: :compat)
      json['players'].each do |player|
        return nil if (!player['payoff'].numeric? || player['payoff'].to_s == 'NaN' || player['payoff'].to_s == 'Inf')
      end
      return_hash = { features: numeralize(json['features']), symmetry_groups: profile.symmetry_groups.collect{ |s| { role: s.role, strategy: s.strategy, count: s.count, players: [], payoff: 0.0, payoff_sd: 0.0 } } }
      return_hash[:symmetry_groups].each do |symmetry_group|
        players = json['players'].select{ |player| player['role'] == symmetry_group[:role] && player['strategy'] == symmetry_group[:strategy]}
        players ||= []
        return nil if players.count != profile.symmetry_groups.where(role: symmetry_group[:role], strategy: symmetry_group[:strategy]).first.count
        symmetry_group[:players] = clean_players(players)
        symmetry_group[:payoff] = symmetry_group[:players].collect{ |player| player[:payoff] }.reduce(:+)/symmetry_group[:players].count
        symmetry_group[:payoff_sd] = Math.sqrt(symmetry_group[:players].collect{ |player| player[:payoff]**2.0 }.reduce(:+)/symmetry_group[:players].count-symmetry_group[:payoff]**2.0)
      end
      return_hash
    rescue Exception => e
      nil
    end
  end

  private

  def self.numeralize(hash)
    return nil if !hash
    return_hash = {}
    hash.each do |key, value|
      return_hash[key] = ( value.numeric? ? value.to_f : ( value.is_a?(Hash) ? numeralize(value) : value ) )
    end
    return_hash
  end

  def self.clean_players(players)
    players.collect do |player|
      { payoff: player['payoff'].to_f, features: numeralize(player['features'])}
    end
  end
end