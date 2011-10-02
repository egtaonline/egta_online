class GameMigration < Mongoid::Migration
  def self.up
    Game.all.each do |g|
      puts g.roles.create!(name: "All", count: g.size, strategy_array: g["strategy_array"])
    end
    mongo_db = Game.db
    mongo_db.collection("games").update({}, {"$unset" => { "strategy_array" => 1}})
  end

  def self.down
  end
end