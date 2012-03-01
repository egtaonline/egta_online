object game
child :roles do
  attributes :name => :name, :count => :count, :strategy_names => :strategy_array
end
child @profiles => :profiles do
  attributes :extended_name => :proto_string
  child :role_instances => :roles do
    attributes :name
    child :strategy_instances => :strategies do
      attributes :name, :payoff
    end
  end
end