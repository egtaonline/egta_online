# TODO: FINISH DATA PARSER

class DataParser
  @queue = :nyx_actions

  def self.perform(number, location="#{Rails.root}/db/#{Simulation.where(number: number).first.account.username}")
    feature_hash = create_feature_hash(number, location)
    feature_hash_array = Array.new
    puts "finding feature names"
    (Dir.entries(location+"/#{number}/features")-[".", ".."]).each {|x| feature_files[x] = File.open(location+"/#{number}/features/"+x) }
    keys = feature_files.keys
    unless keys.size == 0
      puts "loading feature types"
      YAML.load_documents(feature_files[keys[0]]) do |doc|
        feature_hash_array << Hash.new
        feature_hash_array.last[keys[0]] = doc
      end
    end
    puts "loading feature values"
    keys.each_index do |index|
      unless index == 0
        count = 0
        YAML.load_documents(feature_files[keys[index]]) do |doc|
          feature_hash_array[count][keys[index]] = doc
          count += 1
        end
      end
    end
    payoff_data = Array.new
    puts "opening payoff_data"
    File.open(location+"/#{number}/payoff_data") {|io| YAML.load_documents(io) {|yf| payoff_data << yf }}
    begin
      puts "storing payoff data"
      store_in_profile(Simulation.where(:number => number).first.profile, payoff_data, feature_hash_array)
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
      
    end
  end
end