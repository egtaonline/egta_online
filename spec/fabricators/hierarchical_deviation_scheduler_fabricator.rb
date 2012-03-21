Fabricator(:hierarchical_deviation_scheduler) do
  name {Fabricate.sequence(:name, 1) {|i| "scheduler#{i}"}}
  simulator!
  size 120
  agents_per_player 60
  process_memory 1000
  samples_per_simulation 1
  max_samples 2
  time_per_sample 40
  parameter_hash {|g| g.simulator.parameter_hash}
  after_create {|sgs| if sgs.parameter_hash.is_a?(String); sgs.update_attribute(:parameter_hash, eval(sgs.parameter_hash)); end }
end