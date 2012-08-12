Before do |scenario|
  Mongoid.default_session.collections.select {|c| c.name !~ /system/ }.each(&:drop)
end