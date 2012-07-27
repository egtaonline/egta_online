require 'spec_helper'

describe UploadService do
  let(:upload_connection){ double("connection") }
  let(:upload_service){ UploadService.new(upload_connection) }
  
  describe '#upload_simulation!' do
    let(:simulation){ double(number: 3) }
    
    context 'success' do
      before do
        upload_connection.should_receive(:upload!).with("#{Rails.root}/tmp/simulations/3", "#{Yetting.deploy_path}/simulations", recursive: true).and_yield("a", "b", "c", "d")
      end
      
      it{ upload_service.upload_simulation!(simulation).should eql("#{Yetting.deploy_path}/simulations/3") }
    end
    
    context 'failure' do
      before do
        upload_connection.should_receive(:upload!).with("#{Rails.root}/tmp/simulations/3", "#{Yetting.deploy_path}/simulations", recursive: true).and_raise(Exception)
        simulation.should_receive(:fail).with('could not complete the transfer to remote host.  Speak to Ben to resolve.')
      end
      
      it{ upload_service.upload_simulation!(simulation).should eql(nil) }
    end
  end
  
  describe '#upload_simulator!' do
    let(:simulator){ double(name: 'fake_name', fullname: 'fake_name-ver1', simulator_source: double(path: 'path/to/simulator')) }
    
    before do
      upload_connection.should_receive(:upload!).with('path/to/simulator', "#{Yetting.deploy_path}/fake_name.zip")
    end
    
    it{ upload_service.upload_simulator!(simulator) }
  end
end