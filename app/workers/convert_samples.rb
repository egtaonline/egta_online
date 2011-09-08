class ConvertSamples
  @queue = :profile_actions
  
  def self.perform(profile_id)
    profile = Profile.find(profile_id) rescue nil
    if profile != nil
      puts "converting"
      profile.sample_count.times do |i|
        payoff_hash = {}
        profile.profile_entries.each {|pe| payoff_hash[pe.name.split(":")[0]] = pe.samples[i].payoff}
        feature_hash = {}
        profile.features.each {|f| feature_hash[f.name] = f.samples[i].payoff}
        profile.sample_records.create!(payoffs: payoff_hash, features: feature_hash)
      end
      profile.profile_entries.destroy_all
      profile.features.destroy_all
    end
  end
end
