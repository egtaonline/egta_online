object @object

attribute :id
case @granularity
when "summary"
  attribute :sample_count
  child :symmetry_groups do |profile|
    extends "api/v3/profiles/symmetry_group"
  end
when "observation", "full"
  node :observations do |profile|
    1.upto(profile.sample_count).collect do |i|
      partial "api/v3/profiles/observation", :locals => { profile: @object, observation_id: i }
    end
  end
end