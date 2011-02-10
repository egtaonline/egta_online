require 'statsample'

class AdjustmentCoefficientRecord
  include Mongoid::Document
  references_one :game
  embedded_in :simulator
  field :feature_hash, :type => Hash

  def calculate_coefficients(features)
    data = Hash.new
    data["payoffs"] = Array.new
    features.each {|x| data[x.name] = Array.new}
    game.profiles.each do |prof|
      prof.players.each do |play|
        play.payoffs.each do |pay|
          data["payoffs"] << pay.payoff
          features.each {|x| data[x.name] << x.feature_samples.where(:sample_id => pay.sample_id).first.value-x.expected_value}
        end
      end
    end
    data.each_pair {|x,y| data[x] = y.to_scale}
    regression = Statsample::Regression.multiple(data.to_dataset, 'payoffs')
    update_attributes(:feature_hash => regression.coeffs)
  end
end