object resource
child :roles do
  attributes :name, :count, :strategy_array
end
child @profiles => :profiles do
  child :role_instances => :roles do
    attributes :name
    child :strategy_instances => :strategies do
      attributes :name
      code :count do |u|
        u.role_instance.profile.proto_string.split("; ").select{|r| r.split(": ")[0] == u.role_instance.name}[0].split(": ")[1].split(", ").count(u.name)
      end
      attributes :payoff
    end
  end
end