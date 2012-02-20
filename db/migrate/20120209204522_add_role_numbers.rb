class AddRoleNumbers < Mongoid::Migration
  def self.up
    Profile.all.each do |p|
      if p.proto_string.is_a?(String) == false
        p.proto_string = p.proto_string[0]
        puts "failed - " + p.proto_string
      end
      p.proto_string.split("; ").each do |atom|
        puts p.inspect if atom == nil
        role = atom.split(": ")[0]
        puts p.inspect if atom.split(": ")[1] == nil
        p["Role_#{role}_count"] = atom.split(": ")[1].split(", ").size
      end
      p.save
    end
  end

  def self.down
  end
end