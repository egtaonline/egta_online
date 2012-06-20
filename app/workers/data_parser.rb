class DataParser
  include Resque::Plugins::UniqueJob
  @queue = :nyx_actions

  def self.perform(number, location="#{Rails.root}/db/#{Simulation.where(number: number).first.account_username}")
    feature_hash = create_feature_hash(number, location)
    payoff_data = Array.new
    begin
      File.open(location+"/#{number}/payoff_data") {|io| YAML.load_documents(io) {|yf| payoff_data << yf }}
    rescue => e
      Simulation.where(number: number).first.update_attribute(:error_message, "Payoff data was malformed")
      Simulation.where(number: number).first.failure!
      return
    end
    payoff_data.size.times do |i|
      if fully_numeric?(payoff_data[i])
        feature_hash_record = {}
        feature_hash.keys.each do |key|
          feature_hash_record[key] = feature_hash[key][i]
        end
        begin
          Simulation.where(:number => number).first.profile.sample_records.create!(payoffs: payoff_data[i], features: feature_hash_record)
        rescue => e
          Simulation.where(number: number).first.update_attribute(:error_message, "Problem with sample record number #{i}")
          Simulation.where(number: number).first.failure!
          return
        end
      end
    end
    Simulation.where(number: number).first.finish!
  end

  def self.parse_file(file_name, simulation)
    file = file_name.split('/').last
    if !simulation.files.include?(file)
      profile = simulation.profile
      from_json = json_observation(file_name, profile.assignment)
      if from_json
        from_json['players'].each do |player|
          profile.symmetry_groups.where(role: player['role'], strategy: player['strategy']).first.players.create(payoff: player['payoff'], features: player['features'])
        end
        from_json['features'].each do |key, value|
          profile.feature_observations.create(name: key, observation: value)
        end
        profile.inc(:sample_count, 1)
        simulation.push(:files, file)
      end
    end
  end

  def self.json_observation(file_name, assignment)
    begin
      json = Oj.load_file(file_name)
      roles = Hash.new { |hash, key| hash[key] = [] }
      json['players'].each do |player|
        return false if (!numeric?(player['payoff']) || player['payoff'].to_s == 'NaN' || player['payoff'].to_s == 'Inf')
        roles[player['role']] << player['strategy']
      end
      json_assigment = roles.keys.sort.collect{ |role| "#{role}: "+roles[role].sort.uniq.collect{ |strat| "#{roles[role].count(strat)} #{strat}" }.join(", ") }.join("; ")
      json_assigment == assignment ? json : false
    rescue Exception => e
      false
    end
  end
  
  protected
  
  def self.fully_numeric?(hash)
    hash.each do |key, value|
      value.each do |subkey, subvalue|
        return false if (numeric?(subvalue) == false || subvalue.to_s == "NaN")
      end
    end
    true
  end
  
  def self.numeric?(object)
    true if Float(object) rescue false
  end
end