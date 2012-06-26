class SampleRecordsToSymmetryGroups < Mongoid::Migration
  def self.up
    Profile.where(:sample_count.gt => 0).each do |profile|
      profile.symmetry_groups.each {|s| s.players.destroy_all }
      if profile["sample_records"] == [] || profile["sample_records"] == nil
        p profile.inspect
      else
        count = 0
        profile["sample_records"].each do |sample_record|
          count += 1
          profile.symmetry_groups.each do |symmetry_group|
            symmetry_group.count.times{ |i| symmetry_group.players.create(payoff: sample_record["payoffs"][symmetry_group.role][symmetry_group.strategy], observation_id: count) }
          end
        end
        flag = false
        profile.symmetry_groups.each do |symmetry_group|
          flag ||= (symmetry_group.payoff.round(2) != (profile["sample_records"].map{ |s| s["payoffs"][symmetry_group.role][symmetry_group.strategy] }.reduce(:+)/profile["sample_records"].size).round(2))
        end
        puts profile.inspect if flag
      end
    end
  end

  def self.down
  end
end