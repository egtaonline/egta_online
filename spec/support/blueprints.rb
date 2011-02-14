require 'machinist/mongoid'
require 'sham'
require 'faker'

Sham.define do
  sim_name { |index| "Sim#{index}" }
  game_name { |index| "Game#{index}" }
  account_name { |index| "Account#{index}" }
  strategy_name { |index| "Strategy#{index}" }
  feature_name { |index| "Feature#{index}" }
  version { Faker::Lorem.words(1) }
end

Account.blueprint do
  username { Sham.account_name }
  flux { true }
  host { Sham.account_name }
  max_concurrent_simulations { 10 }
end

GameScheduler.blueprint do
  max_samples { 30 }
  samples_per_simulation { 30 }
end

Simulator.blueprint do
  name { Sham.sim_name }
  version
end

SimCount.blueprint do
  counter { 30 }
end

def make_simulator_with_game(attributes = {})
  simulator = Simulator.make(attributes)
  simulator.games << make_game_with_descendents
  SimCount.make
  simulator
end

Game.blueprint do
  name { Sham.game_name }
  size { 2 }
  parameters { ["a", "b"]}
end

def make_game_with_descendents(attributes = {})
  game = Game.make(attributes)
  game.strategies << Strategy.make(:name => "Strategy0")
  game.features << make_feature_with_samples
  game.profiles << make_profile_with_players
  game
end

Strategy.blueprint do
  name { Sham.strategy_name }
end

Profile.blueprint do
  size { 2 }
end

def make_profile_with_players(attributes = {})
  profile = Profile.make(attributes)
  2.times { profile.players << make_players_with_payoffs }
  profile
end

Player.blueprint do
  strategy { "Strategy0" }
end

def make_players_with_payoffs(attributes = {})
  player = Player.make(attributes)
  1.upto(30) {|x| player.payoffs << Payoff.make(:sample_id => x) }
  player
end

Payoff.blueprint do
  payoff { rand }
end

Feature.blueprint do
  name { Sham.feature_name }
  expected_value { 0.5 }
end

def make_feature_with_samples(attributes = {})
  feature = Feature.make(attributes)
  1.upto(30) { |x| feature.feature_samples << FeatureSample.make(:feature_name => feature.name, :sample_id => x) }
  feature
end

FeatureSample.blueprint do
  value { rand }
end