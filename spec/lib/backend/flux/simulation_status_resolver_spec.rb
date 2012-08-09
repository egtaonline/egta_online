require 'spec_helper'

describe SimulationStatusResolver do
  describe '#act_on_status' do
    let(:simulation){ double(number: 3) }
    let(:flux_proxy){ double('flux_proxy') }
    let(:status_resolver){ SimulationStatusResolver.new(flux_proxy) }

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
        flux_proxy.should_receive(:download!).with("#{Yetting.deploy_path}/simulations/#{simulation.number}", "#{Rails.root}/tmp/data", recursive: true).and_return('')
        File.should_receive(:exists?).with("#{Rails.root}/tmp/data/3/error").and_return(true)
        File.should_receive(:open).with("#{Rails.root}/tmp/data/3/error").and_return(double(read: nil))
        Resque.should_receive(:enqueue).with(DataParser, 3)
      end
      
      it{ status_resolver.act_on_status("C", simulation) }
      it{ status_resolver.act_on_status("", simulation) }
      it{ status_resolver.act_on_status(nil, simulation) }
    end
    
    context 'simulation did not complete successfully' do
      before do
        flux_proxy.stub(:download!).with("#{Yetting.deploy_path}/simulations/#{simulation.number}", "#{Rails.root}/tmp/data", recursive: true).and_return('')
        File.stub(:exists?).with("#{Rails.root}/tmp/data/3/error").and_return(true)
        File.should_receive(:open).with("#{Rails.root}/tmp/data/3/error").and_return(double(read: 'I has error'))
        simulation.should_receive(:fail).with('I has error')
      end
      
      it{ status_resolver.act_on_status("C", simulation) }
      it{ status_resolver.act_on_status("", simulation) }
      it{ status_resolver.act_on_status(nil, simulation) }
    end
  end
end