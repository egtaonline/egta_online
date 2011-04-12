require 'stalker'
include Stalker
require File.expand_path("../environment", __FILE__)

job 'update_profiles' do |args|
  game = Game.find(BSON::ObjectId.from_string(args["game"]))
  game.ensure_profiles
end

job 'calc_regret' do |args|
  game = Game.find(BSON::ObjectId.from_string(args["game"]))
  game.ensure_profiles
end