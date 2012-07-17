require "util/sequence"
require 'util/assignment_sorting'
require 'backend/spec_generator'
require 'backend/backend'
require 'backend/simulation_prep_service'

class Object
  def deep_copy
    Marshal.load(Marshal.dump(self))
  end
end