require 'backend/flux_backend'

class Simulation
end

describe FluxBackend do

  context 'setup connections' do
    let(:submission_service){ double('submission_service') }
    let(:flux_proxy){ double('submit_connection') }
    let(:simulator_prep_service){ double('simulator_prep_service') }
    let(:simulation_status_service){ double('simulation_status_service') }
    let(:status_resolver){ double('status_resolver') }
    let(:pbs_wrapper){ double('pbs_wrapper') }

    before do
      DRbObject.stub(:new_with_uri).with('druby://localhost:30000').and_return(flux_proxy)
      SubmissionService.stub(:new).with(flux_proxy, "fake/remote/path").and_return(submission_service)
      SimulatorPrepService.stub(:new).with(flux_proxy, "fake/simulators/path").and_return(simulator_prep_service)
      SimulationStatusService.stub(:new).with(flux_proxy).and_return(simulation_status_service)
      SimulationStatusResolver.stub(:new).with("fake/local/path").and_return(status_resolver)
      PbsWrapper.stub(:new).with("fake/local/path", "fake/remote/path", "fake/simulators/path").and_return(pbs_wrapper)
      subject.flux_simulations_path = "fake/remote/path"
      subject.simulations_path = "fake/local/path"
      subject.simulators_path = "fake/simulators/path"
      subject.setup_connections
    end

    describe '#schedule_simulation' do
      let(:simulation){ double(_id: 3, id: 3) }

      before do
        submission_service.should_receive(:submit).with(simulation, "fake/remote/path")
        remote_command = "[ -f \"fake/remote/path/#{simulation.id}/wrapper\" ] && echo \"exists\" || echo \"not exists\""
        flux_proxy.should_receive(:exec!).with(remote_command).and_return("exists")
      end

      it { subject.schedule_simulation(simulation) }
    end

    describe '#prepare_simulator' do
      let(:simulator){ double(name: 'sim', simulator_source: double(path: 'path/to/simulator')) }

      before 'cleans up the space and uploads the simulator' do
        simulator_prep_service.should_receive(:cleanup_simulator).with(simulator)
        flux_proxy.should_receive(:upload!).with('path/to/simulator', "fake/simulators/path/sim.zip", recursive: true).and_return("")
        flux_proxy.should_receive(:exec!).with("[ -f \"fake/simulators/path/sim.zip\" ] && echo \"exists\" || echo \"not exists\"")
        simulator_prep_service.should_receive(:prepare_simulator).with(simulator, "fake/simulators/path")
      end

      it { subject.prepare_simulator(simulator) }
    end

    describe '#clean_simulation' do
      it 'calls for removal on nfs' do
        FileUtils.should_receive(:rm_rf).with("fake/local/path/3")
        subject.clean_simulation(3)
      end
    end

    describe '#update_simulations' do
      let(:simulation){double(job_id: 123, id: 1)}

      before do
        criteria = double('Criteria')
        criteria.should_receive(:only).with(:job_id).and_return([simulation])
        Simulation.should_receive(:active).and_return(criteria)
      end

      it "calls update_simulation on the status service" do
        simulation_status_service.should_receive(:get_statuses).and_return({ '123' => "C" })
        status_resolver.should_receive(:act_on_status).with("C", 1)
        subject.update_simulations
      end
    end

    describe '#prepare_simulation' do
      let(:pbs_wrapper){ double('pbs_wrapper') }
      let(:simulation){ double(flux: false) }

      before do
        subject.flux_active_limit = 60
        pbs_wrapper.should_receive(:create_wrapper).with(simulation)
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
end