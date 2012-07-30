object @object

attributes :id => :id, :fullname => :simulator_fullname, :configuration => :configuration
child :roles do |r|
  attributes :name, :strategies
end