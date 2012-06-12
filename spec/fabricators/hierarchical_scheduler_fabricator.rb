Fabricator(:hierarchical_scheduler) do
  name { Fabricate.sequence(:name) { |i| "testing#{i}" } }
  simulator!
  size 4
  process_memory 1000
  samples_per_simulation 1
  max_samples 2
  agents_per_player 2
  time_per_sample 40
  configuration { |s| s.simulator.configuration }
  after_create {|sgs| if sgs.configuration.is_a?(String); sgs.update_attribute(:configuration, eval(sgs.configuration)); end }
end

Fabricator(:hierarchical_scheduler_with_profiles, from: :hierarchical_scheduler) do
  roles(:count => 1) { |scheduler, i| Fabricate(:role, :role_owner => scheduler, :name => "All", :count => scheduler.size/scheduler.agents_per_player) }
  after_create do |scheduler| 
    scheduler.roles.first.strategies << "A"
    scheduler.roles.first.strategies << "B"
    ProfileAssociater.perform scheduler.id
  end
end