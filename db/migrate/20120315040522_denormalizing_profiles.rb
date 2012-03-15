class DenormalizingProfiles < Mongoid::Migration
  def self.up
    Profile.all.each do |profile| 
      profile.update_attribute(:name, name2(profile))
      profile.update_attribute(:sample_count, profile.sample_records.count)
    end
  end

  def self.name2(p)
    p.proto_string.split("; ").collect do |role|
      role_name = role.split(": ").first
      strategies = role.split(": ").last.split(", ")
      role_name += ": "
      singular_strategies = ::Strategy.where(:number.in => strategies.uniq).collect {|s| "#{strategies.count(s.number.to_s)} #{s.name}"}
      role_name += singular_strategies.join(", ")
    end.join("; ")  
  end
  
  def self.down
  end
end