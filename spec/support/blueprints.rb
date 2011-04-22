require 'machinist/mongoid'

Account.blueprint do
  username { "bcassell" }
  password {"sh@na1"}
  flux { true }
  max_concurrent_simulations { 10 }
end

PbsGenerator.blueprint do
  process_memory { 1000 }
  qos { "cac" }
  time_per_sample { 10 }
  jobs_per_request { 10 }
end

GameScheduler.blueprint do
  max_samples { 30 }
  samples_per_simulation { 30 }
end

Simulator.blueprint do
  name { "epp_sim" }
  version { "Sim#{sn}" }
  parameters { "---\nweb parameters:\n    number of agents: 120" }
  path { "/Users/bcassell/Ruby/egt_working_directory/epp_sim.zip" }
end

SimCount.blueprint do
  counter { 0 }
end

Game.blueprint do
  name { "Game#{sn}" }
  size { 2 }
  parameters {["number_of_agents"]}
  number_of_agents { 120 }
end

Strategy.blueprint do
  name { "Strategy#{sn}" }
end

Profile.blueprint do
  size { 2 }
end

Player.blueprint do
  strategy { "a" }
end

Simulation.blueprint do
  state { "pending" }
  flux { "true" }
  job_id { 1 }
  size { 30 }
end

Sample.blueprint do
  id {1}
end

User.blueprint do
  email { "test@test.com" }
  password { "stuff1" }
  password_confirmation { "stuff1" }
  secret_key { SECRET_KEY }
end

def make_simulation_with_sample
  simulation = Simulation.make
  simulation.samples << Sample.make
  simulation
end

Sample.blueprint do
  id {1}
end

Payoff.blueprint do
  payoff { rand }
  sample_id {1}
end

Feature.blueprint do
  name { "feature#{sn}" }
  expected_value { 0.5 }
end

FeatureSample.blueprint do
  value { rand }
end