require 'stalker'
include Stalker
require File.expand_path("../environment", __FILE__)

job 'update_profiles' do |args|
  game = Simulator.find(args["simulator"]).games.find(args["game"])
  game.ensure_profiles
end