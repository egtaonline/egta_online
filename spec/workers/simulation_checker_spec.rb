require 'spec_helper'
require 'stringio'

describe SimulationChecker do
  describe 'perform' do
    it 'asks the backend to check each simulation' do
      Backend.should_receive(:update_simulations)
      SimulationChecker.perform
    end
  end
end