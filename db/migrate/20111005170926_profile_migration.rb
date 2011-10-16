class ProfileMigration < Mongoid::Migration
  def self.up
    mongo_db = Profile.db
    mongo_db.collection("profiles").update({}, {"$unset" => { "_type" => 1}}, multi: true)
    total = Profile.count
    count = 0
    while total > 0
      if total < 50
        cursor = Profile.skip(50*count).limit(total)
      else
        cursor = Profile.skip(50*count).limit(50)
      end
      cursor.each do |p|
        p.role_instances.create!(name: "All", payoff_avgs: p["payoff_avgs"], payoff_stds: p["payoff_stds"])
        samples = while_stand_alone_doc(SampleRecord) do
          SampleRecord.where(profile_id: p.id).to_a
        end
        if samples != [] && samples != nil
          p.sample_records = samples
          p.save!
        end
      end
      count += 1
      total -= 50
      puts total
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

