Fabricator(:hierarchical_scheduler) do
  name { Fabricate.sequence(:name) { |i| "testing#{i}" } }
  simulator!
  size 4
  process_memory 1000
  samples_per_simulation 1
  default_samples 2
  time_per_sample 40
  configuration { |s| s.simulator.configuration }
  after_create {|sgs| if sgs.configuration.is_a?(String); sgs.update_attribute(:configuration, eval(sgs.configuration)); end }
end

Fabricator(:hierarchical_scheduler_with_profiles, from: :hierarchical_scheduler) do
  after_create do |scheduler|
    scheduler.add_role("All", 4, 2)
    scheduler.add_strategy("All", "A")
    scheduler.add_strategy("All", "B")
  end
end