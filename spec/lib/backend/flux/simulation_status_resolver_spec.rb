require 'backend/flux/simulation_status_resolver'

class Simulation
end

class DataParser
end

describe SimulationStatusResolver do
  describe '#act_on_status' do
    let(:simulation){ double(_id: 3, id: 3) }
    let(:status_resolver){ SimulationStatusResolver.new("fake/local/path") }

    context 'simulation is running' do
      before do
        Simulation.should_receive(:find).with(3).and_return(simulation)
        simulation.should_receive(:start)
      end

      it{ status_resolver.act_on_status("R", simulation.id) }
    end

    context 'simulation is queued' do
      before do
        Simulation.should_not_receive(:start)
        Simulation.should_not_receive(:fail)
      end

      it{ status_resolver.act_on_status("Q", simulation.id) }
    end

    context 'simulation completed successfully' do
      before do
        Simulation.should_receive(:find).with(3).and_return(simulation)
        File.should_receive(:exists?).with("fake/local/path/3/error").and_return(true)
        File.should_receive(:open).with("fake/local/path/3/error").and_return(double(read: nil))
        simulation.should_receive(:process)
      end

      it{ status_resolver.act_on_status("C", simulation.id) }
      it{ status_resolver.act_on_status("", simulation.id) }
      it{ status_resolver.act_on_status(nil, simulation.id) }
    end

    context 'simulation did not complete successfully' do
      before do
        Simulation.should_receive(:find).with(3).and_return(simulation)
        File.stub(:exists?).with("fake/local/path/3/error").and_return(true)
        File.should_receive(:open).with("fake/local/path/3/error").and_return(double(read: 'I has error'))
        simulation.should_receive(:fail).with('I has error')
      end

      it{ status_resolver.act_on_status("C", simulation.id) }
      it{ status_resolver.act_on_status("", simulation.id) }
      it{ status_resolver.act_on_status(nil, simulation.id) }
    end
  end
end