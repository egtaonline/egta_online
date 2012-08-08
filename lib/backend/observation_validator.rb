class ObservationValidator
  def self.validate(file_name, assignment)
    begin
      json = Oj.load_file(file_name, mode: :compat)
      roles = Hash.new { |hash, key| hash[key] = [] }
      json['players'].each do |player|
        return false if (!player['payoff'].numeric? || player['payoff'].to_s == 'NaN' || player['payoff'].to_s == 'Inf')
        player['payoff'] = player['payoff'].to_f
        roles[player['role']] << player['strategy']
      end
      json_assigment = roles.keys.sort.collect{ |role| "#{role}: "+roles[role].sort.uniq.collect{ |strat| "#{roles[role].count(strat)} #{strat}" }.join(", ") }.join("; ")
      json_assigment == assignment ? json : nil
    rescue Exception => e
      nil
    end
  end
end