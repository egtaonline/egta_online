Fabricator(:profile) do
  simulator_instance!
  assignment "All: 2 A"
end

Fabricator(:sampled_profile, from: :profile) do
  sample_count 1
end

Fabricator(:profile_with_observation, from: :profile) do
  after_create do |profile|
    observation = profile.symmetry_groups.collect do |sgroup|
      players = Array.new(sgroup.count){ |i| { "p" => (i+1)*100 } }
      { players: players, payoff: ArrayMath.average(players.collect{ |pl| pl["p"] }), payoff_sd: ArrayMath.std_dev(players.collect{ |pl| pl["p"] }) }
    end
    profile.observations.create(observation_symmetry_groups: observation)
  end
end