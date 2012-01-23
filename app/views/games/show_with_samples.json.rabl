object resource
child :roles do
  attributes :name, :count => :numberOfPlayers
  child :strategies => :actions do
    attributes :name, :number
  end
end
child @profiles => :profiles do
  child :role_instances => :roleInstances do
    attributes :name, :action_count_map => :actionCountMap
  end
  child :sample_records => :profileObservations do
    attributes :payoffs, :features
  end
end