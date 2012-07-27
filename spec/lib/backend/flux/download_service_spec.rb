require 'spec_helper'

describe DownloadService do
  let(:download_connection){ double("connection") }
  let(:download_service){ DownloadService.new(download_connection, 'tmp/data') }
  
  describe '#download_simulation!' do
    let(:simulation){ double(number: 3) }
    
    context 'success' do
      before do
        download_connection.should_receive(:download!).with("#{Yetting.deploy_path}/simulations/3", "tmp/data", recursive: true).and_yield("a", "b", "c", "d")
      end
      
      it{ download_service.download_simulation!(simulation).should eql("tmp/data/3") }
    end
    
    context 'failure' do
      before do
        download_connection.should_receive(:download!).with("#{Yetting.deploy_path}/simulations/3", "tmp/data", recursive: true).and_raise(Exception)
        simulation.should_receive(:fail).with('could not complete the transfer from remote host.  Speak to Ben to resolve.')
      end
      
      it{ download_service.download_simulation!(simulation).should eql(nil) }
    end
  end
end