class SampleRecordsToSymmetryGroups < Mongoid::Migration
  def self.up
    Simulator.where(:_id => '4f60d65a4a98060bec000002').destroy_all
    profiles = Profile.where(:sample_count.gt => 0, :sample_records.ne => nil).limit(100).to_a
    while profiles != []
      puts Profile.where(:sample_count.gt => 0, :sample_records.ne => nil).count
      profiles.each do |profile|
        count = 0
        profile.symmetry_groups.each do |symmetry_group|
          symmetry_group.players.destroy_all
        end
        profile["sample_records"].each do |sample_record|
          count += 1
          profile.symmetry_groups.each do |symmetry_group|
            symmetry_group.count.times{ |i| symmetry_group.players.create(payoff: sample_record["payoffs"][symmetry_group.role][symmetry_group.strategy], observation_id: count) }
          end
        end
        flag = false
        profile.symmetry_groups.each do |symmetry_group|
          flag ||= (symmetry_group.payoff.round(2) != (profile["sample_records"].map{ |s| s["payoffs"][symmetry_group.role][symmetry_group.strategy] }.to_scale.mean).round(2))
          if flag
            puts "players #{symmetry_group.players.collect{|player| player.payoff}}"
            puts "sample_records #{profile["sample_records"].collect{ |s| s["payoffs"][symmetry_group.role][symmetry_group.strategy] }}"
          end
        end
        profile.unset("sample_records") unless flag
      end
      profiles = Profile.where(:sample_count.gt => 0, :sample_records.ne => nil).limit(100).to_a
    end
  end

  def self.down
  end
end