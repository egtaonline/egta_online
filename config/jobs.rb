require 'stalker'
include Stalker
require File.expand_path("../environment", __FILE__)

@server_proxy = ServerProxy.new
#@server_proxy.start
Stalker.enqueue('schedule_simulations', {}, :delay => 100)
Stalker.enqueue('queue_simulations', {}, :delay => 200)
Stalker.enqueue('maintain_simulations', {}, :delay => 300)

job 'schedule_simulations' do
  puts "process_schedulers"
  Scheduler.active.each do |scheduler|
    scheduler.schedule(30)
  end
  Stalker.enqueue('schedule_simulations', {}, :delay => 100)
end

job 'queue_simulations' do
  puts "queue_simulations"
  @server_proxy.queue_pending_simulations
  Stalker.enqueue('queue_simulations', {}, :delay => 200)
end

job 'maintain_simulations' do
  puts "maintain_simulations"
  @server_proxy.check_simulations
  Stalker.enqueue('maintain_simulations', {}, :delay => 300)
end

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