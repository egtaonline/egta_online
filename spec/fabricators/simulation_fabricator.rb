Fabricator(:simulation) do
  state "queued"
  profile
  account
  generic_scheduler!
  size 2
end