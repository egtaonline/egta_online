Fabricator(:hierarchical_scheduler) do
  name { Fabricate.sequence(:name) { |i| "testing#{i}" } }
  size 4
  process_memory 1000
  samples_per_simulation 1
  max_samples 2
  agents_per_player 2
  time_per_sample 40
  after_create {|sgs| if sgs.parameter_hash.is_a?(String); sgs.update_attribute(:parameter_hash, eval(sgs.parameter_hash)); end }
end