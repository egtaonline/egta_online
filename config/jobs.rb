require 'stalker'
include Stalker
require File.expand_path("../environment", __FILE__)

job 'remove_strategy' do |args|
  game = Game.find(BSON::ObjectId.from_string(args["game"]))
  game.remove_strategy(args["strategy_name"])
end

job 'calculate_cv' do |args|
  game = Game.find(args["game"])
  cv = game.control_variates.find(args["cv"])
  source_game = Game.find(cv.acr_game_id)
  adjustment_coefficient_record = source_game.adjustment_coefficient_records.find(cv.adjustment_coefficient_record_id)
  adjustment_coefficient_record.calculate_coefficients(args["features"].collect {|x| Game.find(cv.acr_game_id).features.where(:name => x).first})
  adjustment_coefficient_record.save!
  cv.update_attributes(:destination_id => cv.transform_game(args["name"]))
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
