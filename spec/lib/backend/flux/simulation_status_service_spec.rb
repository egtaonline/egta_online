require 'spec_helper'

describe SimulationStatusService do
  describe '#get_status' do
    let(:simulation){ double(job_id: 123456) }
    let(:status_connection){ double('status connection') }
    let(:simulation_status_service){ SimulationStatusService.new(status_connection) }

    context 'job present' do
      before do
        status_connection.should_receive(:exec!).with("qstat -a | grep egta-").and_return("123456.nyx.engi     bcassell flux     egta-epp_sim             26276   --   --    --  24:00 Q -- \n123457.nyx.engi     bcassell flux     egta-epp_sim             26278   --   --    --  24:00 C -- ")
      end

      it{ simulation_status_service.get_statuses['123456'].should eql("Q") }
      it{ simulation_status_service.get_statuses['123457'].should eql("C") }
    end

    context 'connection closed' do
      it 'understands the first type of failure' do
        status_connection.should_receive(:exec!).with("qstat -a | grep egta-").and_return("failure, email sent")
        simulation_status_service.get_statuses.should eql("failure")
      end

      it 'understands the second type of failure' do
        status_connection.should_receive(:exec!).with("qstat -a | grep egta-").and_return("failure, email already sent")
        simulation_status_service.get_statuses.should eql("failure")
      end
    end

    context 'job absent' do
      before do
        status_connection.should_receive(:exec!).with("qstat -a | grep egta-").and_return(nil)
      end

      it{ simulation_status_service.get_statuses['123456'].should eql(nil) }
    end
  end
end