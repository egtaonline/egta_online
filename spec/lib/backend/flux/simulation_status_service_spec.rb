require 'spec_helper'

describe SimulationStatusService do
  describe '#get_status' do
    let(:simulation){ double(job_id: 123456) }
    let(:status_connection){ double('status connection') }
    let(:simulation_status_service){ SimulationStatusService.new(status_connection) }
    
    context 'job present' do
      before do
        status_connection.should_receive(:exec!).with("qstat -a | grep 123456 | grep egta-").and_return("123456.nyx.engi     bcassell flux     egta-epp_sim             26276   --   --    --  24:00 Q -- ")
      end
      
      it{ simulation_status_service.get_status(simulation).should eql("Q") }
    end
    
    context 'job absent' do
      before do
        status_connection.should_receive(:exec!).with("qstat -a | grep 123456 | grep egta-").and_return(nil)
      end
      
      it{ simulation_status_service.get_status(simulation).should eql(nil) }
    end
  end
end