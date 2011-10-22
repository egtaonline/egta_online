class Sampled < Mongoid::Migration
  def self.up
    mongo_db = Profile.db
    Profile.all.each do |p|
      if p.sample_records.count != 0
        p.update_attribute(:sampled, true)
      end
    end
    mongo_db.collection("profiles").update({}, {"$unset" => { "payoff_avgs" => 1}}, multi: true)
  end

  def self.down
  end
end