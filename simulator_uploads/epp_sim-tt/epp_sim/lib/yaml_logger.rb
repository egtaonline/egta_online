require 'yaml'

class YAMLLogger
  def initialize(payoff_data_location, feature_data_location)
    @payoff_data_location, @feature_data_location = payoff_data_location, feature_data_location
  end
  
  def record_payoff_data(payoff_data)
    File.open(@payoff_data_location, 'a+') do |out|
      YAML.dump(payoff_data, out )
    end
  end
  
  def record_feature(feature_name, feature_data)
    File.open(@feature_data_location+"/"+feature_name, 'a+') do |out|
      YAML.dump(feature_data, out)
    end
  end
end