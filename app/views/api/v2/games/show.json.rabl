object @object

attributes :id, :name, :simulator_fullname, :parameter_hash
child :roles do |r|
  attributes :name, :count, :strategies
end
child :display_profiles => :profiles do |p|
  extends "api/v2/profiles/show"
end