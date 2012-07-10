class DataParser
  include Resque::Plugins::UniqueJob
  @queue = :nyx_actions

  def self.perform(number, location="#{Rails.root}/db/#{number}")
    simulation = Simulation.where(number: number).first
    if simulation != nil
      Dir.entries(location).keep_if{ |name| name =~ /\A(.*)observation(.)*.json\z/ }.each{ |file| DataParser.parse_file("#{location}/#{file}", simulation) }
      simulation.files == [] ? simulation.failure! : simulation.finish!
    end
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
      else
        simulation.error_message += "#{file_name} was malformed or didn't match the expected profile assignment.\n"
        simulation.save
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