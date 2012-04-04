Fabricator(:simulation) do
  state "queued"
  profile
  account {a = Fabricate.build(:account); a.save(:validate => false); a}
  scheduler {Fabricate(:generic_scheduler)}
  size 2
end