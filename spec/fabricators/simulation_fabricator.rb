Fabricator(:simulation) do
  state "queued"
  profile
  account
  scheduler {Fabricate(:scheduler)}
  size 2
end