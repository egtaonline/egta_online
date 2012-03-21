collection @collection

attributes :id, :name, :simulator_fullname, :parameter_hash
child :roles do |r|
  attributes :name => :name, :count => :count, :strategy_names => :strategies
end