require 'machinist/mongoid'
require 'sham'
require 'faker'

Sham.define do
  sim_name { |index| "Sim#{index}" }
  game_name { |index| "Game#{index}" }
  strategy_name { |index| "Strategy#{index}" }
  feature_name { |index| "Feature#{index}" }
  version { Faker::Lorem.words(1) }
end

Account.blueprint do
  username { "bcassell" }
  flux { true }
  host { "nyx-login.engin.umich.edu"  }
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
  name { Sham.sim_name }
  version
  parameters { "---\nweb parameters:\n    number of agents: 120" }
end

SimCount.blueprint do
  counter { 0 }
end

Game.blueprint do
  name { Sham.game_name }
  size { 2 }
  parameters {["a", "b"]}
end

Strategy.blueprint do
  name { Sham.strategy_name }
end

Profile.blueprint do
  size { 2 }
end

Player.blueprint do
  strategy { "Strategy0" }
end

Simulation.blueprint do
  state { "queued" }
  flux { "true" }
  size { 30 }
end

Sample.blueprint do
  id {1}
end

User.blueprint do
  email { "test@test.com" }
  password { "stuff1" }
  password_confirmation { "stuff1" }
end

Payoff.blueprint do
  payoff { rand }
  sample_id {1}
end

Feature.blueprint do
  name { Sham.feature_name }
  expected_value { 0.5 }
end

FeatureSample.blueprint do
  value { rand }
end