class StrategyInstance
  include Mongoid::Document
  embedded_in :role_instance
  
  field :name
  field :count, :type => Integer
  
  validates_uniqueness_of :name
  validates_presence_of :name, :count
  
  def payoff
    payoffs.mean if role_instance.profile.sample_count != 0
  end
  
  def payoff_sd
    payoffs.sd if role_instance.profile.sample_count != 0
  end
  
  def adjusted_payoffs(cv_manager)
    role_instance.profile.sample_records.collect do |s|
      s.payoffs[role_instance.name][self.name]-(cv_manager.features.collect{|feature| s.features[feature.name] == nil ? 0 : feature.adjustment_coefficient*(s.features[feature.name]-feature.expected_value)}.reduce(:+))
    end.to_scale
  end
  
  private 
  
  def payoffs
    role_instance.profile.sample_records.collect{|s| s.payoffs[role_instance.name][self.name]}.to_scale
  end
end