Fabricator(:simulation) do
  state "queued"
  profile
  account
  scheduler {Fabricate(:generic_scheduler)}
  size 2
end