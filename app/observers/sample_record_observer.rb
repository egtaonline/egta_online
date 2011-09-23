class SampleRecordObserver < Mongoid::Observer
  def after_create(sample_record)
    profile = sample_record.profile
    sample_record.payoffs.each do |key, value|
      profile.payoff_avgs[key] = {} if profile.payoff_avgs[key] == nil
      profile.payoff_stds[key] = {} if profile.payoff_stds[key] == nil
      value.each do |subkey, subvalue|
        if profile.payoff_avgs[key][subkey] == nil
          profile.payoff_avgs[key][subkey] = subvalue
          profile.payoff_stds[key][subkey] = [1, subvalue, subvalue**2, nil]
        else
          profile.payoff_avgs[key][subkey] = (profile.payoff_avgs[key][subkey]*(profile.sample_records.count-1)+subvalue)/profile.sample_records.count
          s0 = profile.payoff_stds[key][subkey][0]+1
          s1 = profile.payoff_stds[key][subkey][1]+subvalue
          s2 = profile.payoff_stds[key][subkey][2]+subvalue**2
          profile.payoff_stds[key][subkey] = [s0, s1, s2, Math.sqrt((s0*s2-s1**2)/(s0*(s0-1)))]
        end
      end
    end
    sample_record.features.each do |key, value|
      if profile.feature_avgs[key] == nil
        profile.feature_avgs[key] = value
        profile.feature_stds[key] = [1, value, value**2, nil]
      else
        profile.feature_avgs[key] = (profile.feature_avgs[key]*(profile.sample_records.count-1)+value)/profile.sample_records.count
        s0 = profile.feature_stds[key][0]+1
        s1 = profile.feature_stds[key][1]+value
        s2 = profile.feature_stds[key][2]+value**2
        profile.feature_stds[key] = [s0, s1, s2, Math.sqrt((s0*s2-s1**2)/(s0*(s0-1)))]
      end
    end
    profile.save!
  end
end