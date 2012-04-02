Fabricator(:sample_record) do
  profile
  payoffs do |sample_record|
    p_hash = {}
    sample_record.profile.role_instances.each do |r|
      s_hash = {}
      r.strategy_instances.each do |s|
        s_hash[s.name] = 1
      end
      p_hash[r.name] = s_hash
    end
    p_hash
  end
end