object resource
child :roles do
  attributes :name, :count, :strategy_array
end
child @profiles => :profiles do
  attributes :proto_string
  child :role_instances => :roles do
    attributes :name
    child :strategy_instances => :strategies do
      attributes :name, :payoff
    end
  end
end