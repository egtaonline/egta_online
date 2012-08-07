require 'spec_helper'

describe DownloadService do
  let(:download_service){ DownloadService.new(30000, 'tmp/data') }
  
  describe '#download_simulation!' do
    let(:simulation){ double(number: 3) }
    
    context 'success' do
      before do
        socket = double(gets: "true")
        TCPSocket.stub(:new).with('localhost', 30000).and_return(socket)
        socket.should_receive(:puts).with(Oj.dump({ type: 'scp', cmd: 'download', src: "#{Yetting.deploy_path}/simulations/3", destination: "tmp/data" }))
        socket.should_receive(:close)
      end
      
      it{ download_service.download_simulation!(simulation).should eql("tmp/data/3") }
    end
    
    context 'failure' do
      before do
        socket = double(gets: "gibberish")
        TCPSocket.stub(:new).with('localhost', 30000).and_return(socket)
        socket.should_receive(:puts).with(Oj.dump({ type: 'scp', cmd: 'download', src: "#{Yetting.deploy_path}/simulations/3", destination: "tmp/data" }))
        simulation.should_receive(:fail).with("could not complete the transfer from remote host: gibberish.  Speak to Ben to resolve.")
        socket.should_receive(:close)
      end
      
      it{ download_service.download_simulation!(simulation).should eql(nil) }
    end
  end
end