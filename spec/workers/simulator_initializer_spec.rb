require 'spec_helper'

describe SimulatorInitializer do
  describe 'perform' do
    before do
      simulator = stub(name: 'fake_name', fullname: 'fake_name-ver1', simulator_source: stub(path: 'path/to/simulator'))
      Simulator.should_receive(:find).with(1).and_return(simulator)
      Backend.should_receive(:prepare_simulator).with(simulator)
    end

    it { subject.perform(1) }
  end
end