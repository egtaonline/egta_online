require 'spec_helper'

describe UploadService do 
  let(:upload_service){ UploadService.new(30000) }
  
  describe '#upload_simulation!' do
    let(:simulation){ double(number: 3) }
    
    context 'success' do
      before do
        socket = double(gets: "true")
        TCPSocket.stub(:new).with('localhost', 30000).and_return(socket)
        socket.should_receive(:puts).with(Oj.dump({ type: 'scp', cmd: 'upload', src: "#{Rails.root}/tmp/simulations/3", destination: "#{Yetting.deploy_path}/simulations" }))
        socket.should_receive(:close)
      end
      
      it{ upload_service.upload_simulation!(simulation).should eql("#{Yetting.deploy_path}/simulations/3") }
    end
    
    context 'failure' do
      before do
        socket = double(gets: "gibberish")
        TCPSocket.stub(:new).with('localhost', 30000).and_return(socket)
        socket.should_receive(:puts).with(Oj.dump({ type: 'scp', cmd: 'upload', src: "#{Rails.root}/tmp/simulations/3", destination: "#{Yetting.deploy_path}/simulations" }))
        simulation.should_receive(:fail).with('could not complete the transfer to remote host: gibberish.  Speak to Ben to resolve.')
        socket.should_receive(:close)
      end
      
      it{ upload_service.upload_simulation!(simulation).should eql(nil) }
    end
  end
  
  describe '#upload_simulator!' do
    let(:simulator){ double(name: 'fake_name', fullname: 'fake_name-ver1', simulator_source: double(path: 'path/to/simulator')) }
    
    context 'success' do
      before do
        socket = double(gets: "true")
        TCPSocket.stub(:new).with('localhost', 30000).and_return(socket)
        socket.should_receive(:puts).with(Oj.dump({ type: 'scp', cmd: 'upload', src: 'path/to/simulator', destination: "#{Yetting.deploy_path}/fake_name.zip" }))
        socket.should_receive(:close)
      end
      
      it{ upload_service.upload_simulator!(simulator).should eql("#{Yetting.deploy_path}/fake_name.zip") }
    end
    
    context 'failure' do
      before do
        socket = double(gets: "gibberish")
        TCPSocket.stub(:new).with('localhost', 30000).and_return(socket)
        socket.should_receive(:puts).with(Oj.dump({ type: 'scp', cmd: 'upload', src: 'path/to/simulator', destination: "#{Yetting.deploy_path}/fake_name.zip" }))
        socket.should_receive(:close)
      end
      
      it{ upload_service.upload_simulator!(simulator).should eql(nil) }
    end
  end
end