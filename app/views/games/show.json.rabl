object game
child :roles do
  attributes :name, :count, :strategies
end
child @profiles => :profiles do
  attributes :extended_name => :name
  child :role_instances => :roles do
    attributes :name
    child :strategy_instances => :strategies do
      attributes :name, :payoff
    end
  end
end