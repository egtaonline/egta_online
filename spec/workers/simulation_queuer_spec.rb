require 'spec_helper'

describe SimulationQueuer do
  describe 'perform' do
    let(:prep_service){ double('prep_service') }
    let(:simulation1){ double('simulation1') }
    let(:simulation2){ double('simulation2') }

    before do
      SimulationPrepService.should_receive(:new).and_return(prep_service)
      Simulation.stub(:queueable).and_return([simulation1, simulation2])
      prep_service.should_receive(:prepare_simulation).with(simulation1)
      Backend.should_receive(:schedule_simulation).with(simulation1)
    end

    context 'success' do
      before do
        prep_service.should_receive(:prepare_simulation).with(simulation2)
        Backend.should_receive(:schedule_simulation).with(simulation2)
      end

      it { subject.perform }
    end
  end
end