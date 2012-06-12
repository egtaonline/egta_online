collection @collection

attributes :id, :name, :simulator_fullname, :configuration
child :roles do |r|
  attributes :name, :count, :strategies
end