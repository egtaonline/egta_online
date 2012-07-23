require 'spec_helper'

describe TransferService do
  let(:transfer_connection){ double("connection") }
  let(:transfer_service){ TransferService.new(transfer_connection) }
  
  describe '#upload_simulation!' do
    let(:simulation){ double(number: 3) }
    
    context 'success' do
      before do
        transfer_connection.should_receive(:upload!).with("#{Rails.root}/tmp/simulations/3", "#{Yetting.deploy_path}/simulations", recursive: true).and_yield("a", "b", "c", "d")
      end
      
      it{ transfer_service.upload_simulation!(simulation).should eql(true) }
    end
    
    context 'failure' do
      before do
        transfer_connection.should_receive(:upload!).with("#{Rails.root}/tmp/simulations/3", "#{Yetting.deploy_path}/simulations", recursive: true).and_raise(Exception)
        simulation.should_receive(:fail).with('could not complete the transfer to remote host.  Speak to Ben to resolve.')
      end
      
      it{ transfer_service.upload_simulation!(simulation).should eql(false) }
    end
  end
  
  describe '#upload_simulator!' do
    let(:simulator){ double(name: 'fake_name', fullname: 'fake_name-ver1', simulator_source: double(path: 'path/to/simulator')) }
    
    before do
      transfer_connection.should_receive(:upload!).with('path/to/simulator', "#{Yetting.deploy_path}/fake_name.zip")
    end
    
    it{ transfer_service.upload_simulator!(simulator) }
  end
end