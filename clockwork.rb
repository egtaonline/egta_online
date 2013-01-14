require File.expand_path('../config/environment', __FILE__)

module Clockwork
  every(1.day, 'SimulationCleaner', at: '01:00'){ SimulationCleaner.perform_async }
  every(3.minutes, 'SimulationQueuer'){ SimulationQueuer.perform_async }
  every(5.minutes, 'SimulationChecker'){ SimulationChecker.perform_async }
end
# end