class SampleRecordsToSymmetryGroups < Mongoid::Migration
  def self.up
    Simulator.where(:_id => '4f60d65a4a98060bec000002').destroy_all
    current_page = 0
    item_count = Profile.where(:sample_count.gt => 0).count
    while item_count > 0
      p item_count
      Profile.where(:sample_count.gt => 0).skip(current_page * 100).limit(100).each do |profile|
        unless profile["sample_records"] == [] || profile["sample_records"] == nil
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
          flag ? (puts profile.id) : profile.unset("sample_records")
        end
      end
      item_count-=100
      current_page+=1
    end
  end

  def self.down
  end
end