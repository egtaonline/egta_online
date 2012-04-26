class SampleRecord
  include Mongoid::Document
  embedded_in :profile
  field :payoffs, :type => Hash, :default => {}
  field :features, :type => Hash, :default => {}
  validates_presence_of :payoffs
  
  def adjusted_payoffs(cv_manager)
    adjusted_payoff_hash = {}
    payoffs.each do |role,strategy_hash|
      adjusted_strategy_hash = {}
      strategy_hash.each do |strategy, payoff|
        adjusted_strategy_hash[strategy] = payoff-(cv_manager.features.collect{|feature| self.features[feature.name] == nil ? 0 : feature.adjustment_coefficient*(self.features[feature.name]-feature.expected_value)}.reduce(:+))
      end
      adjusted_payoff_hash[role] = adjusted_strategy_hash
    end
    adjusted_payoff_hash
  end
end