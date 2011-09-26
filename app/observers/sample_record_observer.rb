class SampleRecordObserver < Mongoid::Observer
  def after_create(sample_record)
    profile = sample_record.profile
    sample_record.payoffs.each do |key, value|
      role = profile.role_instances.find_or_create_by(name: key)
      value.each do |subkey, subvalue|
        if role.payoff_avgs[subkey] == nil
          role.payoff_avgs[subkey] = subvalue
          role.payoff_stds[subkey] = [1, subvalue, subvalue**2, nil]
        else
          role.payoff_avgs[subkey] = (role.payoff_avgs[subkey]*(profile.sample_records.count-1)+subvalue)/profile.sample_records.count
          s0 = role.payoff_stds[subkey][0]+1
          s1 = role.payoff_stds[subkey][1]+subvalue
          s2 = role.payoff_stds[subkey][2]+subvalue**2
          role.payoff_stds[subkey] = [s0, s1, s2, Math.sqrt((s0*s2-s1**2)/(s0*(s0-1)))]
          role.save!
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