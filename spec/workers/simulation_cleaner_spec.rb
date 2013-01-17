require 'spec_helper'

describe SimulationCleaner do
  describe 'perform' do
    before do
      stale_simulations = double("stale")
      stale_simulations.should_receive(:destroy_all)
      first_finished = double("first")
      second_finished = double("second")
      finished_simulations = [first_finished, second_finished]
      finished_simulations.each do |sim|
        sim.should_receive(:requeue)
      end
      Simulation.should_receive(:stale).and_return(stale_simulations)
      Simulation.should_receive(:recently_finished).and_return(finished_simulations)
    end

    it { subject.perform }
  end
end