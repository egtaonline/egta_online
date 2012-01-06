object resource
child :roles do
  attributes :name, :count
end
child @profiles => :profiles do
  attributes :name
  child :role_instances => :roles do
    attributes :name
    child :strategy_instances => :strategies do
      attributes :name, :payoff
    end
  end
end