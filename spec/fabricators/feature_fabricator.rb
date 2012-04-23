Fabricator(:feature) do
  cv_manager
  name {Fabricate.sequence(:name, 1) {|i| "feature#{i}"}}
  expected_value 50.0
end