require 'spec_helper'

describe SubmissionService do
  let(:connection){ double("connection") }
  let(:simulation){ double(_id: 3, id: 3) }
  let(:submission_service){ SubmissionService.new(connection) }

  context 'exercising submission command' do
    context 'successful queue' do
      let(:data){ "123534123.flux-login.engin.umich.edu" }

      before do
        connection.should_receive(:exec!).with("qsub -V -r n #{Yetting.simulations_path}/#{simulation.id}/wrapper").and_return(data)
        simulation.should_receive(:queue_as).with(123534123)
      end

      it{ submission_service.submit(simulation) }
    end

    context 'incomprehensible data' do
      let(:data){ "gibberish" }

      before do
        connection.should_receive(:exec!).with("qsub -V -r n #{Yetting.simulations_path}/#{simulation.id}/wrapper").and_return(data)
        simulation.should_receive(:fail).with("submission failed: gibberish")
      end

      it{ submission_service.submit(simulation) }
    end

    context 'nil data' do
      let(:data){ nil }

      before do
        connection.should_receive(:exec!).with("qsub -V -r n #{Yetting.simulations_path}/#{simulation.id}/wrapper").and_return(data)
        simulation.should_receive(:fail).with("unknown submission failure")
      end

      it{ submission_service.submit(simulation) }
    end

    context 'random error' do
      let(:data){ "123534123.flux-login.engin.umich.edu" }

      before do
        connection.stub(:exec!).with("qsub -V -r n #{Yetting.simulations_path}/#{simulation.id}/wrapper").and_raise("Failure")
        simulation.should_receive(:fail).with("failed in the submission step: Failure")
      end

      it{ submission_service.submit(simulation) }
    end
  end
end