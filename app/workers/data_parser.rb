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
      from_json = Oj.load_file(file_name)
      from_json['players'].each do |player|
        profile.symmetry_groups.where(role: player['role'], strategy: player['strategy']).first.players.create(payoff: player['payoff'], features: player['features'])
      end
      profile.inc(:sample_count, 1)
      simulation.push(:files, file)
    end
  end

  protected

  def self.create_feature_hash(number, location)
    feature_hash = {}
    (Dir.entries(location+"/#{number}/features")-[".", ".."]).each do |x|
      File.open(location+"/#{number}/features/#{x}") do |f|
        YAML.load_documents(f) do |doc|
          feature_hash[x] = [] if feature_hash[x] == nil
          feature_hash[x] << doc
        end
      end
    end
    return feature_hash
  end
  
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