# Manages control variables
class CvManager
  include Mongoid::Document
  embedded_in :game
  embeds_many :features
  
  def remove_feature(feature_id)
    self.features.where(:_id => feature_id).destroy_all
    self.calculate_coefficients if self.features.count > 0
  end
  
  def calculate_coefficients
    payoffs = []
    feature_hash = Hash.new {|hash, key| hash[key] = []}
    self.game.display_profiles.each do |profile|
      profile.sample_records.collect do |sample_record|
        flag = true
        self.features.each do |feature|
          if sample_record.features[feature.name] != nil
            feature_hash[feature.name] << sample_record.features[feature.name]
          else
            flag = false
            break
          end
        end
        if flag
          payoff_array = sample_record.payoffs.values.collect{|r| r.values}.flatten
          payoffs << payoff_array.reduce(:+)/payoff_array.size
        end
      end
    end
    if payoffs != []
      feature_hash.each{|key, value| feature_hash[key] = feature_hash[key].to_scale}
      ds = feature_hash.to_dataset
      ds['payoff'] = payoffs.to_scale
      lr = Statsample::Regression.multiple(ds, 'payoff')
      self.features.each do |feature|
        feature.update_attribute(:adjustment_coefficient, lr.coeffs[feature.name])
      end
    end
  end
end