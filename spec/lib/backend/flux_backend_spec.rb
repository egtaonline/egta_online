require 'spec_helper'

describe FluxBackend do
  describe '#setup_connections' do
    before do
      subject.stub(gets: 'bcassell')
    end
    
    it 'makes the required connections for operation with flux' do
      Net::SSH.should_receive(:start).with('flux-login.engin.umich.edu', 'bcassell')
      Net::SCP.should_receive(:start).with('flux-xfer.engin.umich.edu', 'bcassell')
      subject.setup_connections
    end
  end
  
  context 'setup connections' do
    let(:submission_service){ double('submission_service') }
    let(:upload_service){ double('upload_service') }
    let(:download_service){ double('download_service') }
    let(:simulator_prep_service){ double('simulator_prep_service') }
    let(:simulation_status_service){ double('simulation_status_service') }
    let(:status_resolver){ double('status_resolver') }
  
    before do
      subject.stub(gets: 'bcassell')
      upload_connection = double('upload_connection')
      submission_connection = double('submit_connection')
      Net::SSH.stub(:start).with('flux-login.engin.umich.edu', 'bcassell').and_return(submission_connection)
      Net::SCP.stub(:start).with('flux-xfer.engin.umich.edu', 'bcassell').and_return(upload_connection)
      SubmissionService.stub(:new).with(submission_connection).and_return(submission_service)
      SimulatorPrepService.stub(:new).with(submission_connection).and_return(simulator_prep_service)
      UploadService.stub(:new).with(upload_connection).and_return(upload_service)
      DownloadService.stub(:new).with(upload_connection, 'tmp/data').and_return(download_service)
      SimulationStatusService.stub(:new).with(submission_connection).and_return(simulation_status_service)
      SimulationStatusResolver.stub(:new).with(download_service).and_return(status_resolver)
      subject.setup_connections
    end

    describe '#schedule_simulation' do
      let(:simulation){ double('simulation') }
    
      before do
        submission_service.should_receive(:submit).with(simulation)
        upload_service.should_receive(:upload_simulation!).with(simulation).and_return(true)
      end
    
      it { subject.schedule_simulation(simulation) }
    end
  
    describe '#prepare_simulator' do
      let(:simulator){ double('simulator') }
    
      before 'cleans up the space and uploads the simulator' do
        simulator_prep_service.should_receive(:cleanup_simulator).with(simulator)
        upload_service.should_receive(:upload_simulator!).with(simulator)
        simulator_prep_service.should_receive(:prepare_simulator).with(simulator)
      end
      
      it { subject.prepare_simulator(simulator) }
    end
    
    describe '#update_simulation' do
      let(:simulation){ double('simulation') }
      
      it "calls update_simulation on the status service" do
        simulation_status_service.should_receive(:get_status).and_return("C")
        status_resolver.should_receive(:act_on_status).with("C", simulation)
        subject.update_simulation(simulation)
      end
    end
  end
  
  describe '#prepare_simulation' do
    let(:simulation){ double(flux: false) }
    
    before do
      subject.flux_active_limit = 120
      PbsWrapper.should_receive(:create_wrapper).with(simulation, "#{Rails.root}/tmp/simulations")
    end
    
    context 'flux is oversubscribed' do
      
      before do
        Simulation.stub(:where).with({active: true, flux: true}).and_return(stub(count: 121))
        Simulation.stub(:where).with({active: true, flux: false}).and_return(stub(count: 0))
      end
      
      it 'does not change flux to true' do
        simulation.should_not_receive(:[]).with('flux')
        simulation.should_not_receive(:save)
        subject.prepare_simulation(simulation)
      end
    end
    
    context 'flux is undersubscribed' do
      before do
        Simulation.stub(:where).with({active: true, flux: true}).and_return(stub(count: 100))
        Simulation.stub(:where).with({active: true, flux: false}).and_return(stub(count: 0))
      end
      
      it 'changes flux to true' do
        simulation.should_receive(:[]=).with('flux', true)
        simulation.should_receive(:save)
        subject.prepare_simulation(simulation)
      end
    end
    
    context 'flux is oversubscribed, but so is cac' do
      before do
        Simulation.stub(:where).with({active: true, flux: true}).and_return(stub(count: 120))
        Simulation.stub(:where).with({active: true, flux: false}).and_return(stub(count: 21))
      end
      
      it 'changes flux to true' do
        simulation.should_receive(:[]=).with('flux', true)
        simulation.should_receive(:save)
        subject.prepare_simulation(simulation)
      end
    end
  end
end