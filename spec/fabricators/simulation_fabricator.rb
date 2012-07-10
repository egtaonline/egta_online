Fabricator(:simulation) do
  state "queued"
  profile
  scheduler { Fabricate(:generic_scheduler) }
  size 2
end