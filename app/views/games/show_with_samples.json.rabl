object resource
child :roles do
  attributes :name, :count
end
child @profiles => :profiles do
  attributes :name
  child :sample_records do
    attributes :payoffs, :features
  end
end