class ProfileMigration < Mongoid::Migration
  def self.up
    mongo_db = Profile.db
    mongo_db.collection("profiles").update({}, {"$unset" => { "type" => 1}})
    Profile.all.each do |p|
      puts "creating instance"
      p.role_instances.create!(name: "All", payoff_avgs: p["payoff_avgs"], payoff_stds: p["payoff_stds"])
      puts "getting samples"
      samples = while_stand_alone_doc(SampleRecord) do  
        SampleRecord.where(profile_id: p.id).to_a
      end
      puts samples.size
      p.sample_records = samples
      p.save!
      puts p.sample_records.count
    end
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