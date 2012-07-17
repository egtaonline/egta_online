require 'spec_helper'

describe TransferService do
  describe '#upload!' do
    let(:transfer_connection){ double("connection") }
    let(:transfer_service){ TransferService.new(transfer_connection) }
    let(:simulation){ double(number: 3) }
    
    context 'success' do
      before do
        transfer_connection.should_receive(:upload!).with("#{Rails.root}/tmp/simulations/3", "#{Yetting.deploy_path}/simulations", recursive: true).and_yield("a", "b", "c", "d")
      end
      
      it{ transfer_service.upload!(simulation).should eql(true) }
    end
    
    context 'failure' do
      before do
        transfer_connection.should_receive(:upload!).with("#{Rails.root}/tmp/simulations/3", "#{Yetting.deploy_path}/simulations", recursive: true).and_raise(Exception)
        simulation.should_receive(:fail).with('could not complete the transfer to remote host.  Speak to Ben to resolve.')
      end
      
      it{ transfer_service.upload!(simulation).should eql(false) }
    end
  end
end