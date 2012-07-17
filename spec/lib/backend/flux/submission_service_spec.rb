require 'spec_helper'

describe SubmissionService do
  let(:connection){ double("connection") }
  let(:simulation){ double(number: 3) }
  let(:submission_service){ SubmissionService.new(connection) }
  
  context 'exercising submission command' do
    let(:channel){ double('channel') }
    
    before do
      channel.stub(:[]).with(:host).and_return('flux-login.engin.umich.edu')
      simulation.stub(:flux).and_return(false)
      connection.stub(:exec).with("qsub -V -r n #{Yetting.deploy_path}/simulations/#{simulation.number}/wrapper").and_yield(channel, stream, data).and_return(stub(wait: true))
    end
    
    context 'error stream' do
      let(:data){ double("data") }
      let(:stream){ :std_err }
      
      before do
        simulation.should_receive(:fail).with("submission failed: #{data}")
      end
      
      it{ submission_service.submit(simulation) }
    end
    
    context 'std_out stream' do
      let(:stream){ :std_out }
      
      context 'successful queue' do
        let(:data){ "123534123.flux-login.engin.umich.edu" }
      
        before do
          simulation.should_receive(:queue_as).with(123534123)
        end
      
        it{ submission_service.submit(simulation) }
      end
    
      context 'incomprehensible data' do
        let(:data){ "gibberish" }
      
        before do
          simulation.should_receive(:fail).with("submission failed: gibberish")
        end
      
        it{ submission_service.submit(simulation) }
      end
    
      context 'nil data' do
        let(:data){ nil }
      
        before do
          simulation.should_receive(:fail).with("unknown submission failure")
        end
      
        it{ submission_service.submit(simulation) }
      end
    
      context 'random error' do
        let(:data){ "123534123.flux-login.engin.umich.edu" }
        
        before do
          connection.stub(:exec).with("qsub -V -r n #{Yetting.deploy_path}/simulations/#{simulation.number}/wrapper").and_raise("Failure")
          simulation.should_receive(:fail).with("failed in the submission step: Failure")
        end
      
        it{ submission_service.submit(simulation) }
      end
    end
  end
end