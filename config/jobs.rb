require 'stalker'
include Stalker
require File.expand_path("../environment", __FILE__)

job 'remove_strategy' do |args|
  game = Game.find(BSON::ObjectId.from_string(args["game"]))
  game.remove_strategy(args["strategy_name"])
end

job 'update_profiles' do |args|
  game = Game.find(BSON::ObjectId.from_string(args["game"]))
  game.ensure_profiles
end

job 'calc_regret' do |args|
  game = Game.find(BSON::ObjectId.from_string(args["game"]))
  generate_regret(game)
end

job 'calc_robust_regret' do |args|
  game = Game.find(BSON::ObjectId.from_string(args["game"]))
  generate_robust_regret(game)
end

job 'calc_replicator_dynamics' do |args|
  game = Game.find(BSON::ObjectId.from_string(args["game"]))
  run_replicator_dynamics(game)
end
