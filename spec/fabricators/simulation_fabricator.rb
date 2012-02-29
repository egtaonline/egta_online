Fabricator(:simulation) do
  state "queued"
  profile
  account
  scheduler {Fabricate(:game_scheduler)}
  size 2
end