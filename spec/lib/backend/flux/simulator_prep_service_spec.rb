require 'backend/flux/simulator_prep_service'

describe SimulatorPrepService do
  let(:login_connection){ double("connection") }
  let(:simulator_prep_service){ SimulatorPrepService.new(login_connection, "fake/simulators/path") }
  let(:simulator){ double(name: 'fake_name', fullname: 'fake_name-ver1')}
  
  describe '#cleanup_simulator' do
    before do
      login_connection.should_receive(:exec!).with("rm -rf fake/simulators/path/fake_name-ver1*; rm -rf fake/simulators/path/fake_name.zip")
    end
    
    it { simulator_prep_service.cleanup_simulator(simulator) }
  end
  
  describe '#prepare_simulator' do
    before do
      login_connection.should_receive(:exec!).with("cd fake/simulators/path && unzip -uqq fake_name.zip -d fake_name-ver1 && chmod -R ug+rwx fake_name-ver1")
    end
    
    it { simulator_prep_service.prepare_simulator(simulator) }
  end
end