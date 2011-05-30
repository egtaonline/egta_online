Fabricator(:profile) do
  run_time_configuration { Fabricate(:run_time_configuration) }
end