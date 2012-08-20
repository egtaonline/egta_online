class RemoveUnneededFieldsFromGames < Mongoid::Migration
  def self.up
    Game.where(:cv_manager.exists => true).unset(:cv_manager)
    Game.where(:profile_ids.exists => true).unset(:profile_ids)
  end

  def self.down
  end
end