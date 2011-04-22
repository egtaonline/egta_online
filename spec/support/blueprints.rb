require 'machinist/mongoid'
require ROOT_PATH+"/spec/support/testaccount"

# create this file as testaccount.rb for testing
# require 'machinist/mongoid'
#
# Account.blueprint do
#   username { your username }
#   password { your password }
#   flux { true }
#   max_concurrent_simulations { 10 }
# end

Simulator.blueprint do
  name { "epp_sim" }
  version { "Sim-#{sn}" }
  parameters { "---\nweb parameters:\n    number of agents: 120" }
  path { "/Users/bcassell/Ruby/egt_working_directory/epp_sim.zip" }
end

Game.blueprint do
  name { "Game-#{sn}" }
  size { 2 }
  parameters {["number of agents"]}
  number_of_agents { 120 }
end

Strategy.blueprint do
  name { "Strategy-#{sn}" }
end

Profile.blueprint do
  size { 2 }
  strategy_array { ["a", "b"] }
end

Player.blueprint do
  strategy { "Strategy-0" }
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
  secret_key { SECRET_KEY }
end

Payoff.blueprint do
  payoff { rand }
  sample_id {1}
end

Feature.blueprint do
  name { "Feature-#{sn}" }
  expected_value { 0.5 }
end

FeatureSample.blueprint do
  value { rand }
end