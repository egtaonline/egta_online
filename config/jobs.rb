require 'stalker'
include Stalker
require File.expand_path("../environment", __FILE__)

job 'update_profiles' do |args|
  simulator = Simulator.find(BSON::ObjectId.from_string(args["simulator"]))
  game = simulator.games.find(BSON::ObjectId.from_string(args["game"]))
  game.ensure_profiles
end
