require 'statsample'

class AdjustmentCoefficientRecord
  include Mongoid::Document

  field :feature_hash, :type => Hash
  embedded_in :simulator

  def calculate_coefficients(features)
    game = control_variate.game
    data = Hash.new
    data["payoffs"] = Array.new
    features.each {|x| data[x.name] = Array.new}
    game.profiles.each do |prof|
      prof.players.each do |play|
        play.payoffs.each do |pay|
          data["payoffs"] << pay.payoff
          features.each {|x| data[x.name] << x.feature_samples.where(:sample_id => pay.sample_id).first.value-(x.expected_value ? x.expected_value : x.sample_avg)}
        end
      end
    end
    data.each_pair {|x,y| data[x] = y.to_scale}
    regression = Statsample::Regression.multiple(data.to_dataset, 'payoffs')
    self.update_attributes(:feature_hash => regression.coeffs)
  end
end