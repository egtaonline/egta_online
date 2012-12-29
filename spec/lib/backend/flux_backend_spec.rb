require 'spec_helper'

describe FluxBackend do

  context 'setup connections' do
    let(:submission_service){ double('submission_service') }
    let(:flux_proxy){ double('submit_connection') }
    let(:simulator_prep_service){ double('simulator_prep_service') }
    let(:simulation_status_service){ double('simulation_status_service') }
    let(:status_resolver){ double('status_resolver') }

    before do
      DRbObject.stub(:new_with_uri).with('druby://localhost:30000').and_return(flux_proxy)
      SubmissionService.stub(:new).with(flux_proxy).and_return(submission_service)
      SimulatorPrepService.stub(:new).with(flux_proxy).and_return(simulator_prep_service)
      SimulationStatusService.stub(:new).with(flux_proxy).and_return(simulation_status_service)
      SimulationStatusResolver.stub(:new).with(flux_proxy).and_return(status_resolver)
      subject.setup_connections
    end

    describe '#schedule_simulation' do
      let(:simulation){ double(_id: 3, id: 3) }

      before do
        submission_service.should_receive(:submit).with(simulation)
        flux_proxy.should_receive(:upload!).with("#{Rails.root}/tmp/simulations/#{simulation.id}", "#{Yetting.deploy_path}/simulations", recursive: true).and_return("")
      end

      it { subject.schedule_simulation(simulation) }
    end

    describe '#prepare_simulator' do
      let(:simulator){ double(name: 'sim', simulator_source: double(path: 'path/to/simulator')) }

      before 'cleans up the space and uploads the simulator' do
        simulator_prep_service.should_receive(:cleanup_simulator).with(simulator)
        flux_proxy.should_receive(:upload!).with('path/to/simulator', "#{Yetting.deploy_path}/sim.zip", recursive: true).and_return("")
        flux_proxy.should_receive(:exec!).with("[ -f \"filename\" ] && echo \"exists\" || echo \"not exists\"")
        simulator_prep_service.should_receive(:prepare_simulator).with(simulator)
      end

      it { subject.prepare_simulator(simulator) }
    end
    
    describe '#clean_simulation' do
      let(:simulation){ double(_id: 3, id: 3) }
      
      it 'calls for removal on flux' do
        flux_proxy.should_receive(:exec!).with("rm -rf #{Yetting.deploy_path}/simulations/#{simulation.id}")
        subject.clean_simulation(simulation)
      end
    end

    describe '#update_simulations' do
      let(:simulation){ double(job_id: '123') }

      before do
        Simulation.should_receive(:active).and_return([simulation])
      end

      it "calls update_simulation on the status service" do
        simulation_status_service.should_receive(:get_statuses).and_return({ '123' => "C" })
        status_resolver.should_receive(:act_on_status).with("C", simulation)
        subject.update_simulations
      end
    end
  end

  describe '#prepare_simulation' do
    let(:simulation){ double(flux: false) }

    before do
      subject.flux_active_limit = 60
      PbsWrapper.should_receive(:create_wrapper).with(simulation, "#{Rails.root}/tmp/simulations")
    end

    context 'flux is oversubscribed' do

      before do
        actives = double('actives')
        actives.stub(:where).with(flux: true).and_return(stub(count: 61))
        actives.stub(:where).with(flux: false).and_return(stub(count: 0))
        Simulation.stub(:active).and_return(actives)
      end

      it 'does not change flux to true' do
        simulation.should_not_receive(:[]).with('flux')
        simulation.should_not_receive(:save)
        subject.prepare_simulation(simulation)
      end
    end

    context 'flux is undersubscribed' do
      before do
        actives = double('actives')
        actives.stub(:where).with(flux: true).and_return(stub(count: 50))
        actives.stub(:where).with(flux: false).and_return(stub(count: 0))
        Simulation.stub(:active).and_return(actives)
      end

      it 'changes flux to true' do
        simulation.should_receive(:[]=).with('flux', true)
        simulation.should_receive(:save)
        subject.prepare_simulation(simulation)
      end
    end

    context 'flux is oversubscribed, but so is cac' do
      before do
        actives = double('actives')
        actives.stub(:where).with(flux: true).and_return(stub(count: 61))
        actives.stub(:where).with(flux: false).and_return(stub(count: 21))
        Simulation.stub(:active).and_return(actives)
      end

      it 'changes flux to true' do
        simulation.should_receive(:[]=).with('flux', true)
        simulation.should_receive(:save)
        subject.prepare_simulation(simulation)
      end
    end
  end
end