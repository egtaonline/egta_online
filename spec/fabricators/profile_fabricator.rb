Fabricator(:profile) do
  simulator!
  assignment { { "All" => { "A" => 2 } } }
  configuration! { |p| p.simulator.configuration }
end