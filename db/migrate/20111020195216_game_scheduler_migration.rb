class GameSchedulerMigration < Mongoid::Migration
  def self.up
    mongo_db = Scheduler.db
    mongo_db.collection("schedulers").update({}, {"$set" => { "_type" => "GameScheduler"}}, multi: true)
    puts "got here"
    Scheduler.all.each do |g|
      puts g.roles.create!(name: "All", count: g.size, strategy_array: g["strategy_array"])
      g.update_attributes(:active, false)
    end
    mongo_db = GameScheduler.db
    mongo_db.collection("schedulers").update({}, {"$unset" => { "strategy_array" => 1}}, multi: true)
  end

  def self.down
  end
end