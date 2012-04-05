object @object

attributes :id => :id, :fullname => :simulator_fullname, :parameter_hash => :parameter_hash
child :roles do |r|
  attributes :name, :strategies
end