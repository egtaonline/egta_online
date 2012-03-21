object @object

attributes :id, :fullname => :simulator_fullname, :parameters_hash => :parameters_hash
child :roles do |r|
  attributes :name => :name, :strategy_names => :strategies
end