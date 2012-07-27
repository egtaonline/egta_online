require 'spec_helper'

describe SimulationStatusResolver do
  describe '#act_on_status' do
    let(:simulation){ double(number: 3) }
    let(:download_service){ double('download_service') }
    let(:status_resolver){ SimulationStatusResolver.new(download_service) }

    context 'simulation is running' do
      before do
        simulation.should_receive(:start!)
      end
      
      it{ status_resolver.act_on_status("R", simulation) }
    end
    
    context 'simulation is queued' do
      it{ status_resolver.act_on_status("Q", simulation) }
    end
    
    context 'simulation completed successfully' do
      before do
        download_service.should_receive(:download_simulation!).with(simulation).and_return('tmp/data/3')
        File.should_receive(:exists?).with('tmp/data/3/out').and_return(true)
        File.should_receive(:open).with('tmp/data/3/out').and_return(double(read: nil))
        Resque.should_receive(:enqueue).with(DataParser, 3)
      end
      
      it{ status_resolver.act_on_status("C", simulation) }
      it{ status_resolver.act_on_status("", simulation) }
      it{ status_resolver.act_on_status(nil, simulation) }
    end
    
    context 'simulation did not complete successfully' do
      before do
        download_service.stub(:download_simulation!).with(simulation).and_return('tmp/data/3')
        File.stub(:exists?).with('tmp/data/3/out').and_return(true)
        File.should_receive(:open).with('tmp/data/3/out').and_return(double(read: 'I has error'))
        simulation.should_receive(:fail).with('I has error')
      end
      
      it{ status_resolver.act_on_status("C", simulation) }
      it{ status_resolver.act_on_status("", simulation) }
      it{ status_resolver.act_on_status(nil, simulation) }
    end
  end
end