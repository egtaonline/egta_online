object @object

attributes :id, :name, :simulator_fullname, :simulator_id, :active, :process_memory, :time_per_sample, :samples_per_simulation, :configuration, :nodes
node :sample_hash do |o|
  shash = {}
  o.sample_hash.each do |key, value|
    local_hash = {}
    local_hash["requested_samples"] = value
    local_hash["sample_count"] = Profile.find(key).sample_count
    shash[key] = local_hash
  end
  shash
end