object @object

node :roleInstances do |u|
  role_hash = {}
  u.role_instances.all.each do |r|
    s_hash = {}
    r.strategy_instances.each{|s| s_hash[s.name] = u.strategy_count(r.name, s.name)}
    role_hash[r.name] = s_hash
  end
  role_hash
end

child :sample_records => :profileObservations do |s|
  attributes :payoffs => :payoffMap, :features => :featureMap
end