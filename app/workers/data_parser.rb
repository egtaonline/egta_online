# TODO: FINISH DATA PARSER

class DataParser
  @queue = :nyx_actions

  def self.perform(number, location="#{Rails.root}/db/#{Simulation.where(number: number).first.account.username}")
    puts "loading feature values" 
    feature_hash = create_feature_hash(number, location)
    payoff_data = Array.new
    puts "opening payoff_data"
    File.open(location+"/#{number}/payoff_data") {|io| YAML.load_documents(io) {|yf| payoff_data << yf }}
    begin
      puts "storing payoff data"
      payoff_data.size.times do |i|
        feature_hash_record = {}
        feature_hash.keys.each do |key|
          feature_hash_record[key] = feature_hash[key][i]
        end
        Simulation.where(:number => number).first.profile.sample_records.create!(payoffs: payoff_data[i], feature_hash_record)
      end
      Simulation.where(number: number).first.finish!
    rescue
      puts "malformed payoff data"
      Simulation.where(number: number).first.update_attribute(:error_message, "Payoff data was malformed")
      Simulation.where(number: number).first.failure!
    end
  end
  
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
  end
end