object resource
child :roles do
  attributes :name, :count, :strategy_array
end
child @profiles => :profiles do
  child :role_instances => :roles do
    attributes :name
    child :strategy_instances => :strategies do
      attributes :name, :payoff
    end
  end
end