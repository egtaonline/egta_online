object @object

attributes :id, :name, :simulator_fullname, :configuration

child :roles do
  attributes :name, :strategies, :count
end
child :display_profiles => :profiles do
  extends "api/v3/profiles/show"
end