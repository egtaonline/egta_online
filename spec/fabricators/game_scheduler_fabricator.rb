Fabricator(:game_scheduler) do
  name "testing"
  size 2
  process_memory 1000
  samples_per_simulation 1
  max_samples 2
  time_per_sample 40
  parameter_hash { Hash["a" => "2"] }
  after_create {|sgs| if sgs.parameter_hash.is_a?(String); sgs.update_attribute(:parameter_hash, eval(sgs.parameter_hash)); end }
end