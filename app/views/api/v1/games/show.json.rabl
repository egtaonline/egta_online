object @object

child :roles do |r|
  attributes :name => :name, :count => :numberOfPlayers
  node :actions do |r|
    r.strategies.collect{|s| s.name}
  end
end

child :features => :features do |f|
  attributes :name => :name, :expected_value => :expectedValue
end

child :display_profiles => :profiles do |p|
  extends "api/v1/profiles/show"
end