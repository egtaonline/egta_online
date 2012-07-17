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
  
  #signals trouble
  describe '#schedule' do
    let(:simulation){ double('simulation') }
    
    before do
      subject.stub(gets: 'bcassell')
      transfer_service = double('transfer')
      transfer_service.should_receive(:upload!).with(simulation).and_return(true)
      submission_service = double('submission_service')
      submission_service.should_receive(:submit).with(simulation)
      transfer_connection = double('transfer_connection')
      submission_connection = double('submit_connection')
      Net::SSH.should_receive(:start).with('flux-login.engin.umich.edu', 'bcassell').and_return(submission_connection)
      Net::SCP.should_receive(:start).with('flux-xfer.engin.umich.edu', 'bcassell').and_return(transfer_connection)
      SubmissionService.stub(:new).with(submission_connection).and_return(submission_service)
      TransferService.stub(:new).with(transfer_connection).and_return(transfer_service)
      subject.setup_connections
    end
    
    it { subject.schedule(simulation) }
  end
  
  describe '#prepare_simulations' do
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