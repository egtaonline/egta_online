Fabricator(:strategy) do
  name {Fabricate.sequence(:name, 1) {|i| "strat#{i}"}}
end