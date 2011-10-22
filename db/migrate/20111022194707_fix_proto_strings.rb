class FixProtoStrings < Mongoid::Migration
  def self.up
    Profile.all.each do |p|
      roles = p.proto_string.split("; ").collect do |role|
        role.split(": ")[0]+": "+role.split(": ")[1].split(", ").sort.join(", ")
      end
      p.update_attribute(:proto_string, roles.join("; "))
    end
  end

  def self.down
  end
end