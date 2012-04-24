object @object

attributes :id, :sample_count
child :role_instances => :roles do |r|
  attribute :name
  child :strategy_instances => :strategies do |s|
    attributes :name, :count, :payoff, :payoff_sd
  end
end
if @full == "true"
  child :sample_records do |s|
    extends "api/v2/profiles/_sample_record"
  end
end