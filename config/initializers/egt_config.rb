require 'util/assignment_sorting'
require 'util/object_numerism'
require 'backend/spec_generator'
require 'backend/simulation_prep_service'
require 'backend/observation_processor'
require 'backend/observation_validator'

class Object
  def deep_copy
    Marshal.load(Marshal.dump(self))
  end
end