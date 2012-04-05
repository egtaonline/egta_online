collection @collection

attributes :id, :name, :simulator_fullname, :parameter_hash
child :roles do |r|
  attributes :name, :count, :strategies
end