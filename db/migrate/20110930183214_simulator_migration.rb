class SimulatorMigration < Mongoid::Migration
  def self.up
    Simulator.all.each do |g|
      puts g.roles.find_or_create_by(name: "All", strategy_array: g["strategy_array"])
    end
    mongo_db = Simulator.db
    mongo_db.collection("simulators").update({}, {"$unset" => { "strategy_array" => 1}}, multi: true)
  end

  def self.down
  end
end