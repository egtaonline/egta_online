object @object

attributes :id, :sample_count
child :symmetry_groups do |r|
  attributes :role, :strategy, :count, :payoff, :payoff_sd
end
if @full == "true"
  child :sample_records do |s|
    extends "api/v3/profiles/_sample_record"
  end
end