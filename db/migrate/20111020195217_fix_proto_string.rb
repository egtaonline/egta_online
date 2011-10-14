class FixProtoString < Mongoid::Migration
  def self.up
    Profile.all.each {|p| p.update_attribute(:proto_string, "All: "+p.proto_string)}
  end

  def self.down
  end
end