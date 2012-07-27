require 'spec_helper'

describe SimulatorPrepService do
  let(:login_connection){ double("connection") }
  let(:simulator_prep_service){ SimulatorPrepService.new(login_connection) }
  let(:simulator){ double(name: 'fake_name', fullname: 'fake_name-ver1')}
  
  describe '#cleanup_simulator' do
    before do
      login_connection.should_receive(:exec!).with("rm -rf #{Yetting.deploy_path}/fake_name-ver1*; rm -rf #{Yetting.deploy_path}/fake_name.zip")
    end
    
    it { simulator_prep_service.cleanup_simulator(simulator) }
  end
  
  describe '#prepare_simulator' do
    before do
      Dir.should_receive(:entries).with("fake_name-ver1").and_return(["fake_name"])
      login_connection.should_receive(:exec!).with("cd #{Yetting.deploy_path} && unzip -uqq fake_name.zip -d fake_name-ver1 && chmod -R ug+rwx fake_name-ver1 && mv fake_name-ver1/fake_name fake_name-ver1/fake_name")
    end
    
    it { simulator_prep_service.prepare_simulator(simulator) }
  end
end