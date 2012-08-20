class RemoveUnneededCollections < Mongoid::Migration
  def self.up
    session = Mongoid.default_session
    session['users (Ben Cassell\'s conflicted copy 2011-09-20)'].drop
    session["strategies"].drop
    session["simulators (Ben Cassell's conflicted copy 2011-09-20)"].drop
    session["simulations (Ben Cassell's conflicted copy 2011-09-20)"].drop
    session["simplifying_strategies_strategies"].drop
    session["schedulers (Ben Cassell's conflicted copy 2011-09-20)"].drop
    session["run_time_configurations"].drop
    session["profiles (Ben Cassell's conflicted copy 2011-09-20)"].drop
    session["mongoid_sequence_holders (Ben Cassell's conflicted copy 2011-09-20)"].drop
    session["games (Ben Cassell's conflicted copy 2011-09-20)"].drop
    session["features"].drop
    session["evolver_migrations"].drop
    session["configurations"].drop
    session["accounts (Ben Cassell's conflicted copy 2011-09-20)"].drop
    session["accounts"].drop
  end

  def self.down
  end
end