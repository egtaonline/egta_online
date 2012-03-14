class CleaningUpProfiles < Mongoid::Migration
  def self.up
    mongo_db = Profile.db
    mongo_db.collection("sample_records").drop
    mongo_db.collection("profiles").update({}, {"$unset" => {"profile_entries" => 1}}, multi: true)
    mongo_db.collection("profiles").update({}, {"$unset" => {"run_time_configuration_id" => 1}}, multi: true)
    mongo_db.collection("profiles").update({}, {"$unset" => {"scheduler_ids" => 1}}, multi: true)
    mongo_db.collection("profiles").update({}, {"$unset" => {"game_ids" => 1}}, multi: true)
    mongo_db.collection("profiles").update({}, {"$unset" => {"payoff_stds" => 1}}, multi: true)
  end

  def self.while_stand_alone_doc(klass)	
    begin
   	  klass.embedded = false
      yield	
    ensure
      klass.embedded = true
    end	
  end

  def self.down
  end
end