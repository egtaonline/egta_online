require 'spec_helper'
require 'stringio'

describe SimulationChecker do
  describe 'perform' do
    let(:simulation1){ double('simulation1') }
    let(:simulation2){ double('simulation2') }
    let(:simulations){ [simulation1, simulation2] }
    
    before do
      Simulation.should_receive(:active).and_return(simulations)
    end
    
    it 'asks the backend to check each simulation' do
      Backend.should_receive(:update_simulation).with(simulation1)
      Backend.should_receive(:update_simulation).with(simulation2)
      SimulationChecker.perform
    end
  end
end