class SampleRecordObserver < Mongoid::Observer
  def after_create(sample_record)
    profile = sample_record.profile
    profile.inc(:sample_count, 1)
    sample_record.payoffs.each do |key, value|
      role = profile.role_instances.where(:name => key).first
      role.strategy_instances.each do |strategy|
        payoff_value = value[strategy.name]
        if strategy.payoff == nil
          strategy.payoff = payoff_value
          strategy.payoff_std = [1, payoff_value, payoff_value**2, nil]
          strategy.save!
        else
          strategy.payoff = (strategy.payoff*(profile.sample_count-1)+payoff_value)/profile.sample_count
          s0 = strategy.payoff_std[0]+1
          s1 = strategy.payoff_std[1]+payoff_value
          s2 = strategy.payoff_std[2]+payoff_value**2
          strategy.payoff_std = [s0, s1, s2, Math.sqrt((s0*s2-s1**2)/(s0*(s0-1)))]
          strategy.save!
        end
      end
    end
    profile.save!
  end
end