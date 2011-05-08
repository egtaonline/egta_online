Fabricator(:game) do
  name { Fabricate.sequence(:name) { |i| "testing#{i}" } }
  parameters { [:number_of_agents]}
  size 2
  after_create do |game|
    game.setup_parameters(Hash["number of agents" => 120])
    game_scheduler = Fabricate.build(:game_scheduler)
    game.schedulers << game_scheduler
    game_scheduler.save!
    profile = Fabricate.build(:profile)
    game.profiles << profile
    profile.save!
    simulation = Fabricate.build(:simulation, :scheduler => game_scheduler, :profile => profile)
    game.simulations << simulation
    simulation.save!
  end
end